$(function () {
    var nb = new Notebook({
        input:  $(".footer input"),
        output: $(".output")
    });

    Notebook.openSocket(function (msg) {
        nb.handleMessage(JSON.parse(msg.data));
    });
});
