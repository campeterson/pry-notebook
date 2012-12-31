$(function () {
    var nb = new Notebook({
        output:  $(".output"),
        partial: $(".footer .partial"),
        input:   $(".footer input")
    });

    Notebook.openSocket(function (msg) {
        nb.handleMessage(JSON.parse(msg.data));
    });
});
