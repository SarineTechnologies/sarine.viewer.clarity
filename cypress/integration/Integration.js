describe('Test atoms integration with viewer creator', () => {

    let demoUrl = [Cypress.env('DEMO_VIEWER'), 'demo-ondemand.html?', Cypress.env('DEMO_STONE'), '/', Cypress.env('DEMO_CONFIGURATION')].join('')
     let events = {
        dataLoaded: {}
    }

    before(() => {
        cy.visit(demoUrl)

        cy.document().then((doc) => {
            doc.addEventListener('sarine.data.loaded', (e) => {
                events.dataLoaded = e.detail;
            })
        })

        cy.server()
        cy.route({
            url: '**/json/v1/*/**'
        }).as('sarineJsonResponseRoute')
        cy.wait('@sarineJsonResponseRoute').its('status').should('eq', 200)
        cy.window().then((win) => {
            win.runRenderOnDemand({
                atom: 'clarityView'
            })
        })
    })

    // **** Clarity ****** //
    describe('Clarity', () => {
        it('Check resize image when drag', () => {
            //Click the left nav button

            cy.window().then((win) => {
                win.runRenderOnDemand({
                    atom: 'clarityView'
                })
                cy.wait(1000)
                //Check the position of the toggle handle - should be to the left
                cy.get('sarine-widget[atom="clarityView"] iframe').then(($iframe) => {
                    let $toggleButton = $iframe.contents().find('.cq-beforeafter-handle');
                    cy.wrap($toggleButton).then((element) => {
                        var x = element[0].offsetLeft
                        var y = element[0].offsetHeight
                        cy.wait(10000)
                        cy.wrap($toggleButton).trigger('mousedown')
                            .trigger('mousemove', {
                                which: 1,
                                pageX: x + 40,
                                pageY: y
                            })
                            .trigger('mouseup', {
                                which: 1,
                                pageX: x + 40,
                                pageY: y
                            })
                        cy.wait(1000)
                        var $img = $iframe.contents().find('.cq-beforeafter-resize')
                        cy.wrap($img).then((img) => {
                            let width = img[0].style.width
                            var left = element[0].style.left
                            expect(width).to.equal(left)
                            expect(element[0].offsetLeft).to.not.equal(x)
                        })
                    })

                })
            })
        })
        it('Compare 2 images width', () => {

            cy.window().then((win) => {
                win.runRenderOnDemand({
                    atom: 'clarityView'
                })
                cy.wait(1000)
                cy.get('sarine-widget[atom="clarityView"] iframe').then(($iframe) => {
                    let $toggleButton = $iframe.contents().find('.cq-beforeafter-img')
                    cy.wrap($toggleButton).then(($images) => {
                        expect($images).to.have.lengthOf(2)
                        expect($images[0].width).to.equal($images[0].width)
                    })
                })
            })
        })
        it('Check icon appear according to configuration', () => {
            cy.wait(1000)
            cy.get('sarine-widget[atom="clarityView"] iframe').then(($iframe) => {
                var clarityConfig = $iframe[0].contentWindow.configuration.experiences.filter((i) => {
                    return i.atom == 'clarityView'
                });
                let iconCss = clarityConfig.iconCss || "default-theme";
                var $icon = $iframe.contents().find('.entypo-icon-code');
                expect($icon[0].className).to.contain(iconCss)
            })
        })

        it('Check clarity image equals to the correct resource', () => {
            cy.wait(1000)
            cy.get('sarine-widget[atom="clarityView"] iframe').then(($iframe) => {
                var clarityConfig = $iframe[0].contentWindow.configuration.experiences.filter((i) => {
                    return i.atom == 'clarityView'
                });
                var diamondImage = $iframe[0].contentWindow.stones[0].viewers.resources["clarityDiamondImage"]
                var image = $iframe.contents().find('.cq-beforeafter-img')
                cy.wrap(image).then(($img) => {
                    expect($img[0].src).to.equal(diamondImage)
                })
            })
        })

        it('Check images type appear according to configuration', () => {
            cy.wait(1000)
            cy.get('sarine-widget[atom="clarityView"] iframe').then(($iframe) => {
                var clarityConfig = $iframe[0].contentWindow.configuration.experiences.filter((i) => {
                    return i.atom == 'clarityView'
                });
                let type = clarityConfig.type || "accurate";
                let plottingImage, markingSvg;
                if (type == 'halo') {
                    markingSvg = $iframe[0].contentWindow.stones[0].viewers.resources["clarityHaloMarkingSVG"]
                    plottingImage = $iframe[0].contentWindow.stones[0].viewers.resources['clarityDiamondImageDark']
                } else {
                    markingSvg = $iframe[0].contentWindow.stones[0].viewers.resources["clarityAccurateMarkingSVG"]
                    plottingImage = markingSvg ? $iframe[0].contentWindow.stones[0].viewers.resources['clarityMeshImage'] : $iframe[0].contentWindow.stones[0].viewers.resources['clarityMeshFinalPlottingImage']
                }

                var image = $iframe.contents().find('.cq-beforeafter-img')
                cy.wrap(image).then(($img) => {
                    expect($img[1].src).to.equal(plottingImage)
                })

                if (markingSvg) {
                    let svg = $iframe.contents().find('.cq-beforeafter-resize div svg')
                    expect(svg).to.exist
                }
            })
        })

        it('Check svg style according to configuration', () => {
            cy.wait(1000)
            cy.get('sarine-widget[atom="clarityView"] iframe').then(($iframe) => {
                var clarityConfig = $iframe[0].contentWindow.configuration.experiences.filter((i) => {
                    return i.atom == 'clarityView'
                });
                let defaultStyle = {};
                if (clarityConfig.type == 'halo')
                    defaultStyle = {
                        "fill": "#B3C7EF",
                        "fill-opacity": 0.5,
                        "stroke": "#ffffff",
                        "stroke-width": 7,
                        "stroke-opacity": 0.8
                    }
                else
                    defaultStyle = {
                        "fill": "white",
                        "fill-opacity": 0.5,
                        "stroke": "#4040c4",
                        "stroke-width": 4,
                        "stroke-opacity": 2
                    }
                let markingSvg = $iframe[0].contentWindow.stones[0].viewers.resources["clarityHaloMarkingSVG"] || $iframe[0].contentWindow.stones[0].viewers.resources["clarityAccurateMarkingSVG"];

                if (markingSvg) {
                    let svg = $iframe.contents().find('.cq-beforeafter-resize div svg g')
                    expect(svg).to.exist

                    var attributes = $iframe.contents().find('.cq-beforeafter-resize div svg g')[0].attributes;

                    let elementStyle
                    for (var p in defaultStyle) {
                        elementStyle = clarityConfig.style && clarityConfig.style[p] ? clarityConfig.style[p] : defaultStyle[p].toString();
                        expect(attributes[p].nodeValue).to.equal(elementStyle)
                    }


                }
            })
        })


    })


})