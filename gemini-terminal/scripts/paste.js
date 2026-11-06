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

// Copy: ttyd 1.7.7 ignores OSC 52, so tmux drag-selects (and anything else
// that copies via OSC 52, e.g. Gemini CLI) never reached the browser clipboard.
// window.term is ttyd's xterm.js instance; it appears after the page mounts.
(function () {
    function copy(text) {
        function fallback() {
            var ta = document.createElement('textarea');
            ta.value = text;
            ta.style.position = 'fixed';
            ta.style.opacity = '0';
            document.body.appendChild(ta);
            ta.select();
            try { document.execCommand('copy'); } catch (e) {}
            document.body.removeChild(ta);
            if (window.term) window.term.focus();
        }
        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(text).catch(fallback);
        } else {
            fallback();
        }
    }
    var timer = setInterval(function () {
        if (!window.term || !window.term.parser) return;
        clearInterval(timer);
        window.term.parser.registerOscHandler(52, function (data) {
            var b64 = data.slice(data.indexOf(';') + 1);
            if (!b64 || b64 === '?') return true; // clipboard read requests: ignore
            try {
                var bytes = Uint8Array.from(atob(b64), function (c) { return c.charCodeAt(0); });
                copy(new TextDecoder().decode(bytes));
            } catch (e) {}
            return true;
        });
    }, 200);
})();
