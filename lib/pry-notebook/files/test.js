describe("Pry Notebook", function() {
    beforeEach(function() {
        this.output   = { append: jasmine.createSpy("append") };
        this.input    = { on: jasmine.createSpy("on") };
        this.partial  = { html: jasmine.createSpy("html") };
        this.notebook = new Notebook({
                            output:  this.output,
                            input:   this.input,
                            partial: this.partial
                        });
    });

    var describeMessageType = function(type, options, cb) {
        describe("handling " + type + " responses", function() {
            beforeEach(function() {
                this.notebook.handleMessage(
                    _.extend({}, options, { type: type })
                );

                var call = this.output.append.mostRecentCall;
                this.el  = call && call.args && call.args[0];
            });

            cb.call(this);
        });
    };

    var itAppends = function() {
        it("appends them to the output div", function() {
            expect(this.output.append).toHaveBeenCalled();
        });
    };

    var itUsesClass = function(classname) {
        it("uses the class '" + classname + "'", function() {
            expect(this.el.hasClass(classname)).toBe(true);
        });
    };

    describeMessageType("result", { value: "100" }, function() {
        itAppends();
        itUsesClass("pry-result");

        it("prepends =>", function() {
            expect(this.el.text()).toBe("=> 100");
        });

        it("clears the partial expr", function() {
            expect(this.partial.html).toHaveBeenCalledWith("");
        });
    });

    describeMessageType("output", { value: "hey\nb  ab y" }, function() {
        itAppends();
        itUsesClass("pry-output");

        it("preserves line breaks and whitespace", function() {
            expect(this.el.html()).toBe("hey<br>b&nbsp; ab y");
        });

        it("does not prepend =>", function() {
            expect(this.el.html()).not.toMatch(/^=> /);
        });

        it("does not clear the partial expr", function() {
            expect(this.partial.html).not.toHaveBeenCalled();
        });
    });

    describeMessageType("error", { value: "Some Message" }, function() {
        itAppends();
        itUsesClass("pry-error");
    });

    describeMessageType("continuation", { value: "def x\n  10\n" }, function () {
        it("does not add it to the output area", function () {
            expect(this.output.append).not.toHaveBeenCalled();
        });

        it("adds the partial expression above the input box", function () {
            expect(this.partial.html)
                .toHaveBeenCalledWith("def x<br>&nbsp; 10");
        });
    });
});
