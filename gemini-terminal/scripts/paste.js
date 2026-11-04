// Injected into ttyd's page (see Dockerfile). On Windows/Linux, xterm.js turns
// Ctrl+V into ^V and cancels the browser paste; Gemini CLI then tries to read
// a system clipboard the container doesn't have, so nothing is pasted.
// Stopping the keydown here (capture phase, before xterm sees it) without
// preventDefault lets the browser paste natively, and xterm sends the text as
// a bracketed paste. macOS is left alone: Cmd+V already works there.
if (!/Mac|iPhone|iPad/.test(navigator.platform)) {
    window.addEventListener('keydown', function (e) {
        if (e.ctrlKey && !e.altKey && !e.metaKey && !e.shiftKey && e.key.toLowerCase() === 'v') {
            e.stopImmediatePropagation();
        }
    }, true);
}
