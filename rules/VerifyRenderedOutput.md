A visual or layout change is not verified until you render it and look. Never claim an HTML, CSS, SVG, or UI fix from reading the source. The defect lives in the gap between source and output, so reasoning about the CSS is a hypothesis, not a result.

Render the change before asserting it works: a headless browser screenshot, a real browser, or the running app. For layout and overflow bugs, measure instead of eyeballing. Compare `document.documentElement.scrollWidth` against `window.innerWidth` to detect horizontal overflow, and query for the widest element rather than guessing which one clips.

Screenshots can mislead. A capture taken below the renderer's minimum window width crops a correct layout and reads as a clipping bug (headless Chrome enforces a 500px floor). Confirm the render width equals the capture width, or measure from inside the page, before concluding anything about clipping.

This is the visual-output case of [[VerifyClaims]]: evidence before assertion, applied to pixels.
