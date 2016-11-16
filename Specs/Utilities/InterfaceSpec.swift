////
///  InterfaceSpec.swift
//

@testable import Ello
import Quick
import Nimble
import SVGKit


class InterfaceSpec: QuickSpec {
    override func spec() {
        describe("Interface") {
            describe("Image") {
                describe("image(style:)") {
                    let styles: [(InterfaceImage, InterfaceImage.Style)] = [
                        (.ElloLogo, .Normal),
                        (.Eye, .Selected),
                        (.BreakLink, .White),
                        (.AngleBracket, .Disabled),
                        (.X, .Red),
                    ]
                    for (interfaceImage, style) in styles {
                        it("\(interfaceImage) should have style \(style)") {
                            expect(interfaceImage.image(style)).notTo(beNil())
                        }
                    }
                }

                describe("normalImage") {
                    let normalImages: [InterfaceImage] = [
                        .ElloLogo,
                        .Eye,
                        .Heart,
                        .Repost,
                        .Share,
                        .XBox,
                        .Pencil,
                        .Reply,
                        .Flag,
                        .Comments,
                        .Invite,
                        .Sparkles,
                        .Bolt,
                        .Omni,
                        .Person,
                        .CircBig,
                        .NarrationPointer,
                        .Search,
                        .Burger,
                        .GridView,
                        .ListView,
                        .Reorder,
                        .Camera,
                        .Check,
                        .Arrow,
                        .Link,
                        .BreakLink,
                        .ReplyAll,
                        .BubbleBody,
                        .BubbleTail,
                        .WhiteStar,
                        .BlackStar,
                        .Question,
                        .X,
                        .Dots,
                        .PlusSmall,
                        .CheckSmall,
                        .AngleBracket,
                        .AudioPlay,
                        .VideoPlay,
                        .ValidationLoading,
                        .ValidationError,
                        .ValidationOK,
                    ]
                    for image in normalImages {
                        it("\(image) should have a normalImage") {
                            expect(image.normalImage).notTo(beNil())
                        }
                    }
                }
                describe("selectedImage") {
                    let selectedImages: [InterfaceImage] = [
                        .Eye,
                        .Heart,
                        .Repost,
                        .Share,
                        .XBox,
                        .Pencil,
                        .Reply,
                        .Flag,
                        .Comments,
                        .Invite,
                        .Sparkles,
                        .Bolt,
                        .Omni,
                        .Person,
                        .CircBig,
                        .Search,
                        .Burger,
                        .Reorder,
                        .Camera,
                        .Check,
                        .Arrow,
                        .Link,
                        .ReplyAll,
                        .BubbleBody,
                        .WhiteStar,
                        .BlackStar,
                        .X,
                        .Dots,
                        .PlusSmall,
                        .CheckSmall,
                        .AngleBracket,
                        .ValidationLoading,
                    ]
                    for image in selectedImages {
                        it("\(image) should have a selectedImage") {
                            expect(SVGKSourceLocalFile.internalSourceAnywhereInBundleUsingName("\(image.rawValue)_selected.svg")).toNot(beNil())
                            expect(SVGKImage(named: "\(image.rawValue)_selected.svg").UIImage).toNot(beNil())
                        }
                    }
                }
                describe("whiteImage") {
                    let whiteImages: [InterfaceImage] = [
                        .BreakLink,
                        .BubbleBody,
                        .Camera,
                        .Link,
                        .Pencil,
                        .Arrow,
                        .Comments,
                        .Heart,
                        .PlusSmall,
                        .Invite,
                        .Repost
                    ]
                    for image in whiteImages {
                        it("\(image) should have a whiteImage") {
                            expect(SVGKSourceLocalFile.internalSourceAnywhereInBundleUsingName("\(image.rawValue)_white.svg")).toNot(beNil())
                            expect(SVGKImage(named: "\(image.rawValue)_white.svg").UIImage).toNot(beNil())
                        }
                    }
                }
                describe("disabledImage") {
                    let disabledImages: [InterfaceImage] = [
                        .AngleBracket,
                    ]
                    for image in disabledImages {
                        it("\(image) should have a disabledImage") {
                            expect(SVGKSourceLocalFile.internalSourceAnywhereInBundleUsingName("\(image.rawValue)_disabled.svg")).toNot(beNil())
                            expect(SVGKImage(named: "\(image.rawValue)_disabled.svg").UIImage).toNot(beNil())
                        }
                    }
                }
                describe("redImage") {
                    let redImages: [InterfaceImage] = [
                        .X,
                    ]
                    for image in redImages {
                        it("\(image) should have a redImage") {
                            expect(SVGKSourceLocalFile.internalSourceAnywhereInBundleUsingName("\(image.rawValue)_red.svg")).toNot(beNil())
                            expect(SVGKImage(named: "\(image.rawValue)_red.svg").UIImage).toNot(beNil())
                        }
                    }
                }
            }
        }
    }
}
