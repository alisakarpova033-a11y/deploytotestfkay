import XCTest

final class ScreenshotTests: XCTestCase {

    let app = XCUIApplication()
    var screenshotDir: String {
        let subdir: String
        if let content = try? String(contentsOfFile: "/tmp/screenshot_subdir.txt", encoding: .utf8),
           !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            subdir = content.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            subdir = "Screenshots"
        }
        return "/Users/sadygsadygov/Desktop/new_dom/Swoner/\(subdir)"
    }

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func saveScreenshot(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        let data = screenshot.pngRepresentation
        let url = URL(fileURLWithPath: "\(screenshotDir)/\(name).png")
        try? data.write(to: url)
    }

    @MainActor
    func testCaptureAllScreenshots() throws {
        try? FileManager.default.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true)

        app.launchArguments = ["-hasCompletedOnboarding", "NO"]
        app.launch()
        sleep(3)
        saveScreenshot("01-onboarding-hanger")

        app.terminate()
        app.launchArguments = ["-hasCompletedOnboarding", "YES"]
        app.launch()
        sleep(3)
        saveScreenshot("02-closet-empty")

        let addBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'plus' OR label CONTAINS[c] 'Add'")).firstMatch
        if addBtn.waitForExistence(timeout: 3) {
            addBtn.tap()
            sleep(2)
            saveScreenshot("03-add-clothing-form")

            let nameField = app.textFields["Name"]
            if nameField.waitForExistence(timeout: 2) {
                nameField.tap()
                nameField.typeText("Blue T-Shirt")
            }
            let colorField = app.textFields["e.g. Navy, White, Red"]
            if colorField.waitForExistence(timeout: 2) {
                colorField.tap()
                colorField.typeText("Blue")
            }

            saveScreenshot("04-add-clothing-filled")

            let saveBtn = app.buttons["Save"]
            if saveBtn.waitForExistence(timeout: 2) {
                saveBtn.tap()
                sleep(3)
            }
        }

        saveScreenshot("05-closet-with-item")

        let itemCard = app.staticTexts["Blue T-Shirt"]
        if itemCard.waitForExistence(timeout: 3) {
            itemCard.tap()
            sleep(2)
            saveScreenshot("06-clothing-detail")

            let doneBtn = app.buttons["Done"]
            if doneBtn.waitForExistence(timeout: 2) {
                doneBtn.tap()
                sleep(1)
            } else {
                app.swipeDown()
                sleep(1)
            }
        }

        let window = app.windows.firstMatch

        let outfitsBtn = app.buttons["Outfits"]
        if outfitsBtn.waitForExistence(timeout: 3) {
            outfitsBtn.tap()
            sleep(2)
        } else {
            window.swipeLeft()
            sleep(2)
        }
        saveScreenshot("07-outfits-empty")

        let createFirstBtn = app.buttons["Create First Outfit"]
        if createFirstBtn.waitForExistence(timeout: 3) {
            createFirstBtn.tap()
            sleep(2)
            saveScreenshot("08-outfit-builder")

            let cancelBtn = app.buttons["Cancel"]
            if cancelBtn.waitForExistence(timeout: 2) {
                cancelBtn.tap()
                sleep(1)
            } else {
                app.swipeDown()
                sleep(1)
            }
        } else {
            let plusBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'plus'")).firstMatch
            if plusBtn.waitForExistence(timeout: 2) {
                plusBtn.tap()
                sleep(2)
                saveScreenshot("08-outfit-builder")
                let cancelBtn = app.buttons["Cancel"]
                if cancelBtn.waitForExistence(timeout: 2) {
                    cancelBtn.tap()
                    sleep(1)
                }
            }
        }

        let generatorBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'What to Wear'")).firstMatch
        if generatorBtn.waitForExistence(timeout: 3) {
            generatorBtn.tap()
            sleep(2)
            saveScreenshot("09-outfit-generator")

            let closeBtn = app.buttons["Close"]
            if closeBtn.waitForExistence(timeout: 2) {
                closeBtn.tap()
                sleep(1)
            } else {
                app.swipeDown()
                sleep(1)
            }
        } else {
            saveScreenshot("09-outfits-view")
        }

        let calendarBtn = app.buttons["Calendar"]
        if calendarBtn.waitForExistence(timeout: 3) {
            calendarBtn.tap()
            sleep(2)
        } else {
            window.swipeLeft()
            sleep(2)
        }
        saveScreenshot("10-calendar-page")

        window.swipeUp()
        sleep(1)
        saveScreenshot("11-calendar-today")

        let gearBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'settings' OR label CONTAINS[c] 'gearshape' OR label CONTAINS[c] 'gear'")).firstMatch
        if gearBtn.waitForExistence(timeout: 3) {
            gearBtn.tap()
            sleep(2)
            saveScreenshot("12-settings")
        }
    }
}
