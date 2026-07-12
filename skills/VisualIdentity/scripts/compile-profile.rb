#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "yaml"

options = { prefix: "forge" }
OptionParser.new do |parser|
  parser.banner = "Usage: compile-profile.rb PROFILE [--output FILE] [--prefix NAME]"
  parser.on("--output FILE", "Write CSS to FILE instead of stdout") { |value| options[:output] = value }
  parser.on("--prefix NAME", "CSS custom-property prefix (default: forge)") { |value| options[:prefix] = value }
end.parse!

profile_path = ARGV.shift
abort "profile path required" unless profile_path
abort "unexpected arguments: #{ARGV.join(' ')}" unless ARGV.empty?
abort "invalid prefix" unless options[:prefix].match?(/\A[a-z][a-z0-9-]*\z/)

profile = YAML.safe_load(File.read(profile_path), permitted_classes: [], permitted_symbols: [], aliases: false)
abort "profile must be a mapping" unless profile.is_a?(Hash)
abort "unsupported profile version" unless profile["version"] == 1

required = %w[id name license provenance modes typography spacing radii focus motion]
missing = required.reject { |key| profile.key?(key) }
abort "missing keys: #{missing.join(', ')}" unless missing.empty?
abort "modes.light.colors required" unless profile.dig("modes", "light", "colors").is_a?(Hash)

def declarations(value, path = [], output = [])
  case value
  when Hash
    value.each do |key, child|
      css_key = key.to_s.gsub(/([a-z0-9])([A-Z])/, "\\1-\\2").downcase
      declarations(child, path + [css_key], output)
    end
  when Array
    value.each_with_index { |child, index| declarations(child, path + [(index + 1).to_s], output) }
  else
    output << [path.join("-"), value.to_s]
  end
  output
end

required_colors = %w[
  canvas surface elevated ink muted inverse border rule brand-primary
  brand-secondary brand-accent on-primary focus success warning danger info
  link series-1 series-2 series-3 series-4 series-5 series-6 series-7 series-8
  grid axis annotation
]
profile.fetch("modes").each do |mode_name, mode|
  colors = mode.is_a?(Hash) ? mode["colors"] : nil
  abort "modes.#{mode_name}.colors must be a mapping" unless colors.is_a?(Hash)
  absent = required_colors.reject { |name| colors.key?(name) }
  abort "modes.#{mode_name}.colors missing: #{absent.join(', ')}" unless absent.empty?
end

def rule(selector, values, prefix)
  body = declarations(values).map { |name, value| "  --#{prefix}-#{name}: #{value};" }.join("\n")
  "#{selector} {\n#{body}\n}"
end

globals = profile.slice("typography", "spacing", "radii", "focus", "motion")
css = ["/* Generated from #{File.basename(profile_path)}; edit profile, not this file. */"]
css << rule(":root", globals, options[:prefix])
css << rule(':root, [data-theme="light"]', { "color" => profile.dig("modes", "light", "colors") }, options[:prefix])
if profile.dig("modes", "dark", "colors")
  css << rule('[data-theme="dark"]', { "color" => profile.dig("modes", "dark", "colors") }, options[:prefix])
end
css << "@media (prefers-reduced-motion: reduce) {\n  :root {\n    --#{options[:prefix]}-motion-durations-fast: var(--#{options[:prefix]}-motion-reduced-motion);\n    --#{options[:prefix]}-motion-durations-base: var(--#{options[:prefix]}-motion-reduced-motion);\n    --#{options[:prefix]}-motion-durations-slow: var(--#{options[:prefix]}-motion-reduced-motion);\n  }\n}"
output = css.join("\n\n") + "\n"

if options[:output]
  File.write(options[:output], output)
else
  $stdout.write(output)
end
