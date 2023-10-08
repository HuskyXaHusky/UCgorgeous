# UCgorgeous v1.01
![Static Badge](https://img.shields.io/badge/UC-gorgeous-%233BB143) 

# Contents
- [Documentation](#documentation) 
- ### Macros:
- [@StructCopy](#structcopy)
- [@ClassImplicitCopy](#classimplicitcopy)
- [@ClassExplicitCopy](#classexplicitcopy)
- [@GetColor](#getcolor)

## About

A small package aimed at the beauty of the code in your project, which contains the most primitive but useful universal macros that you can easily modify to suit your project.  
These macros will allow you to avoid cluttering your project with utilitarian functions and extensions that could not be expressed as a generic function or if the function call is very cumbersome.  
Primitive, reliable, excellent :)

It's important to understand that swift macros have annoying limitations that prevent you from inserting any code anywhere. More precisely, you can insert it, but it won’t work. Thus, it is not possible to create a mass of truly useful macros.
I created this package with a lot of ideas, but most of them were broken by the modest macro capabilities in the process of working on it.
  I sincerely hope that the developers will come to their senses and expand the capabilities of macros in the future.
Then you and I will definitely have fun :)

## Usage

Download package via SPM (Swift Package Manager)  
Don't forget to **import UCgorgeous** into a file to use the provided macros.

## Comes with

Valid tests.  
Description of the purpose of the function with an example of use.

# Documentation

To view rendered documentation in Xcode, open the 
UCgorgeous package and select

```
Product > Build Documentation
``` 

## **StructCopy**  <sup><sub>[origin](#contents)
 A macro that adding  method `copy` to a `struct`.
The `copy` method allows creating a new `struct` with customized property values while retaining the original
other values. 
This way, you don't have to create a new `struct` and fill out its "fields" if you want to change one or a couple values.
The more values there are in the `struct`, the more useful the method provided by the macro will be.
Please note that computed properties are ignored!
 For example,

```swift   
@StructCopy  
     struct Settings: Equatable, Hashable { 
        let pinned: [ String ]
        let customNames: [ String : String ]
        let id: Int?
         var pinsCount: Int {
             return pinned.count
         }
     }
```

produce method:

```swift
    func copy(pinned: [ String ]? = .none, customNames: [ String : String ]? = .none, id: Int?? = .none) -> Settings {
         Settings(pinned: pinned ?? self.pinned, customNames: customNames ?? self.customNames, id: id ?? self.id)
    }
```

 Usage:
 
```swift
    let oldSettings = Settings(pinned: ["1", "2"], customNames: ["07245724": "Rofl"], id: nil)
    let newSetting = oldSettings.copy(id: 120)
```
---
## **ClassImplicitCopy**  <sup><sub>[origin](#contents)
 A macro that adding  method `copy` to a `class`.
 The `copy` method allows creating a new instance of the `class` with customized property values while retaining the original
 instance's other values.
 This way, you don't have to create a new instance of a `class` and fill out its "fields" if you want to change one or a couple values.
 The more values there are in the `class`, the more useful the method provided by the macro will be.
 Please note that computed properties are ignored!
 This is suitable if you want `to use the current property values if they were not passed as parameters`.  
 For example,

```swift
     @ClassImplicitCopy
     final class MainState {
        var onlineStatus: String? = "online"
        var chats: [String] = []
        var chatsDict: [String:String] = [:]
        var chatsCount: Int {
            return chats.count
        }
     }
```

 produce method:

```swift
     func copy(onlineStatus: String?? = .none, chats: [String]? = .none, chatsDict: [String: String]? = .none) -> MainState {
         let result = MainState()
         result.onlineStatus = onlineStatus ?? self.onlineStatus
         result.chats = chats ?? self.chats
         result.chatsDict = chatsDict ?? self.chatsDict
         return result
     }
```

 Usage:

```swift
     let oldState = MainState()
     let newState = oldState.copy(chats: ["MainChat", "P2PChat", "HolyWarPublicChat"])
```

---
## **ClassExplicitCopy**  <sup><sub>[origin](#contents)
 A macro that adding  method `copy` to a `class`.
 The `copy` method allows creating a new instance of the `class` with customized property values while retaining the original
 instance's other values.
 This way, you don't have to create a new instance of a `class` and fill out its "fields" if you want to change one or a couple values.
 The more values there are in the `class`, the more useful the method provided by the macro will be.
 Please note that computed properties are ignored!
 This is suitable if you want `to explicitly specify values for all properties`.  
 Keep in mind that for the macro to be used correctly, the `properties must be initialized` properly.  
 For example,

```swift
     @ClassExplicitCopy
     final class SubState {
        var onlineStatus: String? = "online"
        var chats: [String] = []
        var chatsDict: [String:String] = [:]
        var chatsCount: Int {
            return chats.count
        }
        init(onlineStatus: String? = nil, chats: [String], chatsDict: [String : String]) {
            self.onlineStatus = onlineStatus
            self.chats = chats
            self.chatsDict = chatsDict
        }
     }
```

 produce method:

```swift
     func copy(onlineStatus: String?? = .none, chats: [String]? = .none, chatsDict: [String: String]? = .none) -> SubState {
         SubState(
             onlineStatus: onlineStatus ?? self.onlineStatus,
             chats: chats ?? self.chats,
             chatsDict: chatsDict ?? self.chatsDict
         )
     }
```

 Usage:

```swift
     let oldState = SubState(chats: [], chatsDict: [:])
     let newState = oldState.copy(onlineStatus: "offline", chats: ["P2PChat", "HolyWarPublicChat"])
```

---
## **GetColor**  <sup><sub>[origin](#contents)

A macro that adding  method that returns the `color` associated with the `capitalized` enum `case`.
 When the method is called on an instance of the enum, it returns the corresponding color object.
 This allows for easy access to a set of predefined colors in the application. For example,

```swift
     @GetColor
     enum ColorSet {
         case red
         case green
         case megaCustomColorInAsset
     }
```

 produce method:

```swift
     var color: Color {
         switch self {
         case .red:
             return Color("Red")
         case .green:
             return Color("Green")
         case .megaCustomColorInAsset:
             return Color("MegaCustomColorInAsset")
         }
     }
```

 when need color:

```swift
     Color(ColorSet.megaCustomColorInAsset.color)
```

## License  <sup><sub>[origin](#contents)

MIT License
