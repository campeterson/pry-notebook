describe("Pry Notebook", function() {
    beforeEach(function () {
        this.output   = { append: jasmine.createSpy("append") };
        this.input    = { on: jasmine.createSpy("on") };
        this.notebook = new Notebook({
                            output: this.output,
                            input: this.input
                        });
    });

    describe("handling return values", function () {
        beforeEach(function () {
            this.notebook.handleMessage({
                type:  "value",
                value: "100"
            });

            var call = this.output.append.mostRecentCall;
            this.el  = call && call.args && call.args[0];
        });

        it("appends them to the output div", function() {
            expect(this.output.append).toHaveBeenCalled();
        });

        it("uses the class 'pry-value'", function() {
            expect(this.el.hasClass("pry-value")).toBe(true);
        });
    });

    describe("handling errors", function () {
        beforeEach(function () {
            this.notebook.handleMessage({
                type:  "error",
                value: "An Error Message"
            });

            var call = this.output.append.mostRecentCall;
            this.el  = call && call.args && call.args[0];
        });

        it("appends them to the output div", function() {
            expect(this.output.append).toHaveBeenCalled();
        });

        it("uses the class 'pry-error'", function() {
            expect(this.el.hasClass("pry-error")).toBe(true);
        });
    });
});
