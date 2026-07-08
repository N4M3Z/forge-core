// Capture screenshots + axe-core reports per the DesignReview contract:
//   <target>__<state>__<viewport>.png / .axe.json
import { chromium } from 'playwright';
import AxeBuilder from '@axe-core/playwright';
import { mkdirSync, writeFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import { resolve } from 'node:path';

const [,, htmlFile, target, variant = 'good', statesArg = 'default,empty,loading,error'] = process.argv;
if (!htmlFile || !target) {
    console.error('usage: node capture.mjs <html-file> <target-name> [variant] [states]');
    process.exit(1);
}

const viewports = { mobile: { width: 390, height: 844 }, desktop: { width: 1440, height: 900 } };
const states = statesArg.split(',');
const outDir = resolve('artifacts');
mkdirSync(outDir, { recursive: true });

const browser = await chromium.launch();
for (const [viewportName, size] of Object.entries(viewports)) {
    const context = await browser.newContext({ viewport: size, reducedMotion: 'reduce' });
    const page = await context.newPage();
    for (const state of states) {
        const url = `${pathToFileURL(resolve(htmlFile))}?state=${state}&variant=${variant}`;
        await page.goto(url, { waitUntil: 'networkidle' });
        await page.evaluate(() => document.fonts.ready);
        const base = `${outDir}/${target}__${state}__${viewportName}`;
        await page.screenshot({ path: `${base}.png`, fullPage: true });
        const axeResults = await new AxeBuilder({ page })
            .withTags(['wcag2a', 'wcag2aa', 'wcag21aa', 'wcag22aa'])
            .analyze();
        const compact = {
            target, state, viewport: viewportName, url,
            violations: axeResults.violations.map(r => ({ id: r.id, impact: r.impact, help: r.help, nodes: r.nodes.map(n => ({ target: n.target, summary: n.failureSummary })) })),
            incomplete: axeResults.incomplete.map(r => ({ id: r.id, help: r.help, nodes: r.nodes.map(n => ({ target: n.target })) })),
            passes: axeResults.passes.map(r => r.id),
        };
        writeFileSync(`${base}.axe.json`, JSON.stringify(compact, null, 2) + '\n');
        console.log(`${target}__${state}__${viewportName}: ${compact.violations.length} violations, ${compact.incomplete.length} incomplete`);
    }
    await context.close();
}
await browser.close();
