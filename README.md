# WeatherApp

Пример простого iOS-приложения на UIKit, показывающего прогноз погоды на 5 дней для выбранного города.

***

🚀 Особенности
	•	Один экран со списком прогноза на сегодня + 4 дня.
	•	Архитектура MVVM + Coordinator.
	•	Асинхронные запросы через async/await + URLSession.
	•	In-memory кэш JSON-ответа (TTL 30 мин) и иконок (NSCache).
	•	Поддержка Pull-to-Refresh и Offline-режима.
	•	Минимальная версия iOS 16, Swift 5.9+, UIKit only.
	•	Покрытие Unit- и Snapshot-тестами (в разработке).

***

## 🗂 Структура проекта

```
WeatherApp/
├── WeatherApp/
│   ├── App/
│   ├── Config/
│   ├── Core/
│   │   ├── Network/
│   │   └── Cache/
│   ├── Features/
│   │   └── Forecast/
│   │       ├── Model/
│   │       ├── ViewModel/
│   │       ├── View/
│   │       └── Coordinator/
│   ├── Shared/
│   ├── Utils/
│   │   └── Extensions/
│   └── Resources/
├── Tests/
│   ├── CoreTests/
│   ├── ForecastTests/
│   └── TestUtils/
```

**Пояснения:**
- `App/` — AppDelegate, SceneDelegate  
- `Config/` — Base.xcconfig, Debug.xcconfig, Release.xcconfig  
- `Core/Network/` — WeatherService, NetworkSession, WeatherAPIEndpoint, WeatherAPIError  
- `Core/Cache/` — ForecastCache, ImageCache + protocols  
- `Features/Forecast/View/` — Cells, ViewController  
- `Shared/` — Metrics  
- `Utils/Extensions/` — UIView+AutoLayout, DateFormatter+Forecast, UITableView+ReuseIdentifier  
- `Resources/` — Assets, LaunchScreen  


***

## 📋 Требования

Компонент	Версия
Xcode	15 +
iOS SDK	16 +
Swift	5.9 +


***

## 🔧 Быстрый старт

### 1. Клонирование

git clone https://github.com/your-org/WeatherApp.git
cd WeatherApp
open WeatherApp.xcodeproj

### 2. Настройка API-ключа WeatherAPI

WeatherApp использует бесплатный API https://www.weatherapi.com/
	1.	Зарегистрируйтесь и получите WEATHER_API_KEY.
	2.	Скопируйте шаблон конфигурации и добавьте ключ:

```swift
cp Config/Base.xcconfig Config/private.xcconfig
echo "WEATHER_API_KEY = <ВАШ_КЛЮЧ>" >> Config/private.xcconfig
```

3.	Откройте Project → Info → Configurations и убедитесь, что три схемы (Base, Debug, Release) подключены к соответствующим файлам.
4.	Добавьте Config/private.xcconfig в .gitignore, чтобы ключ не попал в VCS:

```
# WeatherAPI secret
Config/private.xcconfig
```

5.	(Опционально) Для CI/архива используйте переменную окружения:

```
WEATHER_API_KEY=<ключ> xcodebuild ...
```


> ⚠️ Если ключ не найден, приложение завершится с fatalError("Weather API key not set") — это защитит от случайного пропуска шага.

### 3. Сборка и запуск
1. Выберите схему Debug.
2.	Нажмите Run ▶︎ — приложение запустится на симуляторе.
3.	Потяните список вниз, чтобы вручную обновить данные.

***

## 🧪 Тестирование

# Unit- и Snapshot-тесты
xcodebuild test -workspace WeatherApp.xcodeproj \
              -scheme "WeatherApp" \
              -destination "platform=iOS Simulator,name=iPhone 15"


***

## 📝 Принятые решения
- MVVM + Coordinator — разделение навигации, логики представления и бизнес-логики.
- DI URLSession — облегчает Unit-тестирование (подмена на URLProtocolMock).
- MemoryCache с TTL и totalCostLimit — простая кэш-стратегия без сторонних зависимостей.
- Локализация и Dynamic Type — ответственность за доступность.
- Секреты через .xcconfig — ключ остаётся только локально.

***

## 🤖 Автор

Алексей Ефимов

GitHub: @LexDeBash

Telegram: @debash

LinkedIn: Алексей Ефимов
