<p align="center">
<img src="Documents/header.png" srcset="Documents/header.png 1x Documents/header@2x.png 2x" /><br/>
<a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-3-orange.svg" /></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" /></a>
<a href="https://cocoapods.org"><img src="https://img.shields.io/cocoapods/v/CoreValue.svg" /></a>
<img src="https://img.shields.io/cocoapods/p/CoreValue.svg" />
</p>



##Features

- Uses Swift Reflection to convert value types to NSManagedObjects
- iOS and Mac OS X support
- Use with `structs`
- Works fine with `let` and `var` based properties
- Swift 3.0 (for Swift 2.2 use [Version 0.2](https://github.com/terhechte/CoreValue/releases/tag/v0.2.0))

##Rationale

Swift introduced versatile value types into the iOS and Cocoa development domains. They're lightweight, fast, safe, enforce immutability and much more. However, as soon as the need for CoreData in a project manifests itself, we have to go back to reference types and `@objc`. 

CoreValue is a lightweight wrapper framework around Core Data. It takes care of `boxing` value types into Core Data objects and `unboxing` Core Data objects into value types. It also contains simple abstractions for easy querying, updating, saving, and deleting.

If you're porting your app to Swift 3, please see the Swift 3 section at the bottom.

##Usage

The following struct supports boxing, unboxing, and keeping object state:

``` Swift
struct Shop: CVManagedPersistentStruct {
    
    // The name of the CoreData entity
    static let EntityName = "Shop"
    
    // The ObjectID of the CoreData object we saved to or loaded from
    var objectID: NSManagedObjectID?
    
    // Our properties
    let name: String
    var age: Int32
    var owner: Owner?
    
    // Create a Value Type from a NSManagedObject
    // If this looks too complex, see below for an explanation and alternatives
    static func fromObject(_ o: NSManagedObject) throws -> XShop {
        return try curry(self.init)
            <^> o <|? "objectID"
            <^> o <| "name"
            <^> o <| "age"
            <^> o <|? "owner"
    }
}
```


That's it. Everything else it automated from here. Here're some examples of what you can do with `Shop` then:


``` Swift
	// Get all shops (`[Shop]` is required for the type checker to get your intent!)
	let shops: [Shop] = Shop.query(self.context, predicate: nil)
	
	// Create a shop
	let aShop = Shop(objectID: nil, name: "Household Wares", age: 30, owner: nil)
	
	// Store it as a managed object
	aShop.save(self.context)
	
	// Change the age
	aShop.age = 40
	
	// Update the managed object in the store
	aShop.save(self.context)
	
	// Delete the object
	aShop.delete(self.context)
	
	// Convert a managed object into a shop (see below)
	let nsShop: Shop? = try? Shop.fromObject(aNSManagedObject)
	
	// Convert a shop into an nsmanagedobject
	let shopObj = nsShop.mutatingToObject(self.context)
	
```



## Querying

There're two ways of querying objects from Core Data into values:

``` Swift
// With Sort Descriptors
public static func query(context: NSManagedObjectContext, predicate: NSPredicate?, sortDescriptors: Array<NSSortDescriptor>) -> Array
    
// Without sort descriptors
public static func query(context: NSManagedObjectContext, predicate: NSPredicate?) -> Array

```

If no NSPredicate is given, all objects for the selected Entity are returned.

##Usage in Detail

`CVManagedPersistentStruct` is a type alias for the two primary protocols of CoreValue: `BoxingPersistentStruct`, `UnboxingStruct`.

Let's see what they do.

### BoxingPersistentStruct

Boxing is the process of taking a value type and returning a NSManagedObject. CoreValue really loves you and that's why it does all the hard work for you via Swift's `Reflection` feature. See for yourself:

``` Swift
struct Counter : BoxingStruct
    static let EntityName = "Counter"
	var count: Int
	let name: String
}
```

That's it. Your value type is now Core Data compliant. Just call `aCounter.toObject(context)` and you'll get a properly encoded `NSManagedObject`!

If you're interested, have a look at the `internalToObject` function in CoreValue.swift, which takes care of this.

#### Boxing in Detail

Keen observers will have noted that the structure above actually doesn't implement the `BoxingPersistentStruct` protocol, but instead something different called `BoxingStruct`, what's happening here?

By default, Value types are immutable, so even if you define a property as a var, you still can't change it from within except by declaring your function mutable. Swift also doesn't allow us to define properties in protocol extensions, so any state that we wish to assign on a value type has to be via specific properties on the value type.

When we create or load an NSManagedObject from Core Data, we need a way to store the connection to the original NSManagedObject in the value type. Otherwise, calling save again (say after updating the value type) would not update the NSManagedObject in question, but instead *insert a new NSManagedObject* into the store. That's obviously not what we want.

Since we cannot implicitly add any state whatsoever to a protocol, we have to do this explicitly. That's why there's a separate protocol for persistent storage:

``` Swift
struct Counter : BoxingPersistentStruct
    let EntityName = "Counter"
    
    var objectID: NSManagedObjectID?
    
	var count: Int
	let name: String
}
```

The main difference here is the addition of `objectID`. Once this property is there, `BoxingPersistentStruct`'s bag of wonders (.save, .delete, .mutatingToObject) can be used.

What's the usecase of the `BoxingStruct` protocol then, you may ask. The advantage is that `BoxingStruct` does not require your value type to be mutable, and does not extend it with any mutable functions by default, keeping it a truly immutable value type. It still can use `.toObject` to convert a value type into an NSManagedObject, however it can't modify this object afterwards. So it is still useful for all scenarios where you're only performing insertions (like a cache, or a log) or where any modifications are performed in bulk (delete all), or where updating will be performed on the NSManagedObject itself (.valueForKey, .save).

#### Boxing and Sub Properties

A word of advice: If you have value types in your value types, like:

``` Swift
struct Employee : BoxingPersistentStruct {
    let EntityName = "Employee"
    var objectID: NSManagedObjectID?
    let name: String
}

struct Shop : BoxingPersistentStruct {
    let EntityName = "Counter"
    var objectID: NSManagedObjectID?
    let employees: [Employee]
}
```

Then ***you have to make sure*** that all value types conform to the same boxing protocol, either `BoxingPersistentStruct` or `BoxingStruct`. The type checker cannot check this and report this as an error.

#### Ephemeral Objects

Most protocols in CoreValue mark the NSManagedObjectContext as an optional, which means that you don't have to supply it. Boxing will still work as expected, only the resulting NSManagedObjects will be ephemeral, that is, they're not bound to a context, they can't be stored. There're few use cases for this, but it is important to note that not supplying a NSManagedObjectContext will not result in an error.


### UnboxingStruct

In CoreValue, `boxed` refers to values in an NSManagedObject container. I.e. NSNumber is boxing an Int, NSOrderedSet an Array, and NSManagedObject itself is boxing a value type (i.e. `Shop`).

`UnboxingStruct` can be applied to any struct or class that you intend to initialize from a NSManagedObject. It only has one requirement that needs to be implemented, and that's `fromObject` which takes a NSManagedObject and should return a value type. Here's a very simple and unsafe example:

``` Swift
struct Counter : UnboxingStruct
	var count: Int
	let name: String
	static func fromObject(_ object: NSManagedObject) throws -> Counter {
	return Counter(count: object.valueForKey("count")!.integerValue,
           name: object.valueForKey("name") as! String)
	}
}
```

Even though this example is not safe, we can observe several things from it. First, the implementation overhead is minimal. Second, the method can throw an error. That's because unboxing can fail in a multitude of ways (wrong value, no value, wrong entity, unknown entity, etc). If unboxing fails in any way, we throw an `NSError`. The other benefit of unboxing, that it allows us to take a shortcut (which CoreValue deviously copied from [Argo](https://github.com/thoughtbot/Argo)). Utilizing several custom operators, the unboxing process can be greatly simplified:

``` Swift
struct Counter : UnboxingStruct
	var count: Int
	let name: String
	static func fromObject(_ object: NSManagedObject) throws -> Counter {
		return try curry(self.init) <^> object <| "count" <*> object <| "name"
	}
}
```

This code takes the automatic initializer, curries it and maps it over multiple incarnations of unboxing functions (`<|`) until it can return a Counter (or throw an error).

But what about these weird runes? Here's an in-detail overview of what's happening here:

#### Unboxing in Detail

`curry(self.init)`

Convert `(A, B) -> T` into `A -> B -> C` so that it can be called step by step

`<^>`
Map the following operations over the `A -> B -> fn` that we just created

`object <| "count"`
First operation: Take `object`, call `valueForKey` with the key `"count"` and assign this as the value for the first type of the curryed init function `A`

`object <| "name"`
Second operation: Take `object`, call `valueForKey` with the key `"count"` and assign this as the value for the second type of the curryed init function `B`

#### Other Operators

Custom Operators are observed as a critical Swift feature, and rightly so. Too many of those make a codebase difficult to read and understand. The following custom operators are the same as in several other Swift Frameworks (see Runes and Argo). They're basically a verbatim copy from Haskell, so while that doesn't make them less custom or even official, they're at least unofficially agreed upon.

`<|` is not the only operator needed to encode objects. Here's a list of all supported operators:

           Operator                     | Description
:-----:|----------------------------------------------------------
 <^>   |  Map the following operations (i.e. combine map operations)
 <\|   |  Unbox a normal value (i.e. var shop: Shop)
 <\|\| |  Unbox a set/list of values (i.e. var shops: [Shops])
 <\|?  |  Unbox an optional value (i.e. var shop: Shop?)

### CVManagedStruct

Since most of the time you probably want boxing and unboxing functionality, CoreValue includes two handy type aliases, `CVManagedStruct` and `CVManagedPersistentStruct` which contain Boxing and Unboxing in one type.

### `RawRepresentable` Enum support

By extending `RawRepresentable`, you can use Swift `enums` right away without having to first make sure your enum conforms to `CVManagedStruct`.

```
enum CarType:String{
    case Pickup = "pickup"
    case Sedan = "sedan"
    case Hatchback = "hatchback"
}

extension CarType: Boxing,Unboxing {}
 
 struct Car: CVManagedPersistentStruct {
     static let EntityName = "Car"
     var objectID: NSManagedObjectID?
     var name: String
     var type: CarType
     
     static func fromObject(_ o: NSManagedObject) throws -> Car {
         return try curry(self.init)
             <^> o <|? "objectID"
             <^> o <| "name"
             <^> o <| "type"
     }
}
```

## Docs
Have a look at [CoreValue.swift](https://github.com/terhechte/CoreValue/blob/master/CoreValue/CoreValue.swift), it's full of docstrings

Alternatively, there's a lot of usage in the [Unit Tests](https://github.com/terhechte/CoreValue/blob/master/CoreValueMacTests/CoreValueTests.swift).

Here's a  more complex example of CoreValue in use:

``` Swift
struct Employee : CVManagedPersistentStruct {
    
    static let EntityName = "Employee"
    
    var objectID: NSManagedObjectID?

    let name: String
    var age: Int16
    let position: String?
    let department: String
    let job: String
    
    static func fromObject(_ o: NSManagedObject) throws -> Employee {
        return try curry(self.init)
            <^> o <| "objectID"
            <^> o <| "name"
            <^> o <| "age"
            <^> o <|? "position"
            <^> o <| "department"
            <^> o <| "job"
    }
}

struct Shop: CVManagedPersistentStruct {
    static let EntityName = "Shop"
    
    var objectID: NSManagedObjectID?

    var name: String
    var age: Int16
    var employees: [Employee]
    
    static func fromObject(_ o: NSManagedObject) throws -> Shop {
        return try curry(self.init)
            <^> o <| "objectID"
            <^> o <| "age"
            <^> o <| "name"
            <^> o <|| "employees"
    }
}

// One year has passed, update the age of our shops and employees by one
let shops: [Shop] = Shop.query(self.managedObjectContext, predicate: nil)
for shop in shops {
    shop.age += 1
    for employee in shop.employees {
        employee.age += 1
    }
    shop.save()
}

```

## CVManagedUniqueStruct and REST / Serialization / JSON

All the examples we've seen so far resolve around a use case where data is contained within your app. This means that the unique identifier of a NSManagedObject or Struct is dicated by the NSManagedObjectID unique identifier which Core Data generates. This is fine as long as you don't plan to interact with outside data. If your data is loaded from external sources (i.e. JSON from a Rest API) then it may already have a unique identifier. `CVManagedUniqueStruct`  allows you to force CoreValue / Core Data to use this external unique identifier in NSManagedObjectID's stead. The implementation is easy. You just have to conform to the `BoxingUniqueStruct` protocol which requires the implementation of a var naming the unique id field and a function returning the current ID value:

``` Swift
/** Name of the Identifier in the CoreData (e.g: 'id')
  */
static var IdentifierName: String {get}

/** Value of the Identifier for the current struct (e.g: 'self.id')
  */
func IdentifierValue() -> IdentifierType
```

Here's a complete & simple example:

``` Swift
struct Author : CVManagedUniqueStruct {
    
    static let EntityName = "Author"
    
    static var IdentifierName: String = "id"
    
    func IdentifierValue() -> IdentifierType { return self.id }
    
    let id: String
    let name: String
    
    static func fromObject(_ o: NSManagedObject) throws -> Author {
        return try curry(self.init)
            <^> o <| "id"
            <^> o <| "name"
    }
}

```

Please not that `CVManagedUniqueStruct` adds an (roughly) O(n) overhead on top of `NSManagedObjectID` based solutions due to the way object lookup is currently implemented.

## State

All Core Data Datatypes are supported, with the following **exceptions**:
- Transformable
- Unordered Collections / NSSet (Currently, only ordered collections are supported)

Fetched properties are not supported yet.


## Swift 3.0 Conversion

The Swift 3.0 conversion changed a few things within the framework. In order to make it easier, here's a list of things to do:

1. Replace `<*>` operators with `<^>`
2. Replace `func fromObject(object)` with `func fromObject(_ object)`
3. Replace `return curry(self.init)...` with `return try curry(self.init)...`

## Installation (iOS and OSX)

### [CocoaPods]

[CocoaPods]: http://cocoapods.org

Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```ruby
pod 'CoreValue'
```

You will also need to make sure you're opting into using frameworks:

```ruby
use_frameworks!
```

Then run `pod install` with CocoaPods 1.01 or newer.

### [Carthage]

[Carthage]: https://github.com/Carthage/Carthage

Add the following to your Cartfile:

```
github "terhechte/CoreValue" ~> 0.3.0
```

Then run `carthage update`.

Follow the current instructions in [Carthage's README][carthage-installation]
for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

The `import CoreValue` directive is required in order to use CoreValue.


### Manually

1. Copy the CoreValue.swift and curry.swift file into your project.
2. Add the `Core Data` framework to your project

There is no need for `import CoreValue` when manually installing.


## Contact

Benedikt Terhechte 

[@terhechte](http://www.twitter.com/terhechte)

[Appventure.me](http://appventure.me)

## Changelog

### Version 0.3.0
- Swift 3 Support
- Added CVManagedUniqueStruct thanks to [tkohout](https://github.com/tkohout)

### Version 0.2.0
- Switched Error Handling from `Unboxed` to Swift's native `throw`. Big thanks to [Adlai Holler](https://github.com/Adlai-Holler) for spearheading this!
- Huge Performance improvements: Boxing is roughly 80% faster and Unboxing is roughly 90% faster
- Improved support for nested collections thanks to [Roman Kříž](https://github.com/samnung).
- RawRepresentable support (see documentation above) thanks to [tkohout](https://github.com/tkohout)

### Version 0.1.6
- Made `CVManagedPersistentStruct` public
- Fixed issue with empty collections

### Version 0.1.4
Included pull request from AlexanderKaraberov which
includes a fix to the delete function

### Version 0.1.3
Updated to most recent Swift 2.0 b4 changes

### Version 0.1.2
Renamed NSManagedStruct and NSPersistentManagedStruct to CVManagedStruct and CVPersistentManagedStruct as [NS is preserved prefix for Apple classes](https://github.com/terhechte/CoreValue/issues/1)

### Version 0.1.1
Added CocoaPods support

### Version 0.1.0
Initial Release

## Acknoledgements

CoreValue uses ideas and code from [thoughtbot's Argo framework for JSON decoding](https://github.com/thoughtbot/Argo). Most notably their `curry` implementation. Have a look at it, it is an awesome framework.

## License

The CoreValue source code is available under the MIT License.

## Open Tasks

- [ ] test unboxing with custom initializers (init(...))
- [ ] change the protocol composition so that the required implementations (entityname, objectID, fromObject) form an otherwise empty protocol so it is easier to see the protocol and implement the requirements
- [ ] add travis build
- [ ] support aggregation
- [ ] add support for nsset / unordered lists
- [ ] add support for fetched properties (could be a struct a la (objects, predicate))
- [ ] support transformable: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdNSAttributes.html
- [ ] add jazzy for docs and update headers to have proper docs
- [ ] document multi threading support via objectID

