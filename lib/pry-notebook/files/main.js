$(function () {
    var nb = new Notebook({ input: ".input input", output: ".output" });

    Notebook.openSocket(function (msg) {
        nb.handleMessage(JSON.parse(msg.data));
    });
});
