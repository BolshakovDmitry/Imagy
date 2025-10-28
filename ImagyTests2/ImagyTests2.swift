//
//  ImagyTests2.swift
//  ImagyTests2
//
//  Created by Home on 14.03.2025.
//

import XCTest

final class ImagyTests2: XCTestCase {

    private let app = XCUIApplication() // переменная приложения
        
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app.launchArguments.append("UITestMode")
        app.launch()
        
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
    }
        
    func testAuth() throws {
        // Проверяем, нужно ли выйти из аккаунта
        if !app.buttons["Authenticate"].exists {
            app.tabBars.buttons.element(boundBy: 1).tap()
            app.buttons["logout button"].tap()
            app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        }
        
        // Нажимаем кнопку "Authenticate"
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Кнопка 'Authenticate' не найдена")
        authButton.tap()
        
        // Ожидаем появления webView
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 15), "WebView не найден")
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        Thread.sleep(forTimeInterval: 0.5)
        loginTextField.typeText("ВАШ НИК")
        
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        Thread.sleep(forTimeInterval: 0.5)
        passwordTextField.tap()
        Thread.sleep(forTimeInterval: 0.5)

        passwordTextField.typeText("ВАШ ПАРОЛЬ")
        webView.swipeUp()
        
        // Нажимаем кнопку "Login"
        webView.buttons["Login"].tap()
        
        // Ожидаем появления первой ячейки
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Первая ячейка не найдена")
    }
        
    func testFeed() throws {
        // Находим первую ячейку
        let cell = app.tables.children(matching: .cell).firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Ячейка не найдена")
        
        // Прокручиваем, если ячейка не видна
        if !cell.isHittable {
            app.swipeUp()
        }
        
        // Проверяем, что ячейка доступна для взаимодействия
        XCTAssertTrue(cell.isHittable, "Ячейка недоступна для взаимодействия")
        
        // Прокручиваем вверх
        cell.swipeUp()
        
        // Взаимодействие с кнопками лайка
        let likeOffButton = cell.buttons["LikeOff"]
        XCTAssertTrue(likeOffButton.waitForExistence(timeout: 5), "Кнопка 'LikeOff' не найдена")
        
        // Прокручиваем, если кнопка не видна
        if !likeOffButton.isHittable {
            app.swipeUp()
        }
        
        // Нажимаем на кнопку "LikeOff"
        likeOffButton.tap()
        
        // Ожидаем появления кнопки "LikeOn"
        let likeOnButton = cell.buttons["LikeOn"]
        XCTAssertTrue(likeOnButton.waitForExistence(timeout: 3), "Кнопка 'LikeOn' не найдена")
        
        // Нажимаем на кнопку "LikeOn"
        likeOnButton.tap()
        
        // Ожидаем появления кнопки "LikeOff"
        XCTAssertTrue(likeOffButton.waitForExistence(timeout: 3), "Кнопка 'LikeOff' не найдена")
        
        // Нажимаем на ячейку
        cell.tap()
        
        // Ожидаем 2 секунды
        sleep(2)
        
        // Находим изображение и выполняем зум
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1) // zoom in
        image.pinch(withScale: 0.5, velocity: -1) // zoom out
        
        // Возвращаемся назад
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
        
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
       
        XCTAssertTrue(app.staticTexts["nameLabel"].exists)
        XCTAssertTrue(app.staticTexts["usernameLabel"].exists)
        
        app.buttons["logout button"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(
            authButton.waitForExistence(timeout: 10))
    }
    }
