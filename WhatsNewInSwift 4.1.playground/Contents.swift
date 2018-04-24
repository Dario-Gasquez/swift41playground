
//: [Previous](@previous)
//:## Conditional Conformance

/*:
 Conditional conformance enables protocol conformance for generic types where the type arguments satisfy certain conditions [SE-0143]. This is a powerful feature that makes your code more flexible. You can see how it works with a few examples.
 */

class LeadInstrument: Equatable {
    let brand: String
    
    init(brand: String) {
        self.brand = brand
    }
    
    func tune() -> String {
        return "Standard tuning."
    }
    
    static func ==(lhs: LeadInstrument, rhs: LeadInstrument) -> Bool {
        return lhs.brand == rhs.brand
    }
}

class Keyboard: LeadInstrument {
    override func tune() -> String {
        return "Keyboard tunning."
    }
}

class Guitar: LeadInstrument {
    override func tune() -> String {
        return "Guitar tunning."
    }
}

class Band<LeadInstrument> {
    let name: String
    let lead: LeadInstrument
    
    init(name: String, lead: LeadInstrument) {
        self.name = name
        self.lead = lead
    }
}

extension Band: Equatable where LeadInstrument: Equatable {
    static func ==( lhs: Band<LeadInstrument>, rhs: Band<LeadInstrument>) -> Bool {
        return lhs.name == rhs.name && lhs.lead == rhs.lead
    }
}

let rolandKeyboard = Keyboard(brand: "Roland")
let rolandBand = Band(name: "Ronalkeys", lead: rolandKeyboard)

let yamahaKeyboard = Keyboard(brand: "Yamaha")
let yamahaBand = Band(name: "Yamaband", lead: yamahaKeyboard)
let sameKeyBands =  (rolandBand == yamahaBand)

let fenderLead = Guitar(brand: "Fender")
let fenderBand = Band(name:"Fender boys", lead: fenderLead)

let ibanezGuitar = Guitar(brand: "Ibanez")
let ibanezBand = Band(name: "Ibanez Band", lead: ibanezGuitar)

let sameGuitarBands = (fenderBand == ibanezBand)


//:### Conditional Conformance in JSON Parsing
import Foundation

struct Student: Codable, Hashable {
    let firstName: String
    let averageGrade: Int
}

let cosmin = Student(firstName: "Cosmin", averageGrade: 9)
let george = Student(firstName: "George", averageGrade: 10)
let coder = JSONEncoder()

// Encode an array of students
let students = [cosmin, george]
do {
    try coder.encode(students)
} catch {
    print(error.localizedDescription)
}


// Encode a dictionary with students values
let studentsDictionary = ["Comin": cosmin, "George": george]
do {
    try coder.encode(studentsDictionary)
} catch {
    print(error.localizedDescription)
}

// Encode a set of students
let studentsSet: Set = [cosmin, george]
do {
    try coder.encode(studentsSet)
} catch {
    print(error.localizedDescription)
}

// Encode an optional student
let optionalStudent: Student? = cosmin
do {
    try coder.encode(optionalStudent)
} catch {
    print(error.localizedDescription)
}


//: ## Convert Between CamelCase and snake_case During JSON Encoding
var jsonData = Data()
coder.keyEncodingStrategy = .convertToSnakeCase
coder.outputFormatting = .prettyPrinted

do {
    jsonData = try coder.encode(students)
} catch {
    print(error.localizedDescription)
}
if let jsonString = String(data: jsonData, encoding: .utf8) {
    print(jsonString)
}

// Go back to Camel Case from snake_case:
var studentsInfo: [Student] = []
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
do {
    studentsInfo = try decoder.decode([Student].self, from: jsonData)
    print(studentsInfo)
} catch {
    print(error.localizedDescription)
}

for studentInfo in studentsInfo {
    print("\(studentInfo.firstName) - \(studentInfo.averageGrade)")
}

//:## Equatable and Hashable Protocols Conformance
// Swift 4 required boilerplate code to conform to Equatable & Hashable:
struct Country: Hashable {
    let name: String
    let capital: String
    
    static func ==(lhs: Country, rhs: Country) -> Bool {
        return lhs.name == rhs.name && lhs.capital == rhs.capital
    }
    
    var hashValue: Int {
        return name.hashValue ^ capital.hashValue &* 16777619
    }
}

// This allowed to compare countries, add them to sets and use them as dictionary keys:
let france = Country(name: "France", capital: "Paris")
let germany = Country(name: "Germany", capital: "Berlin")
let sameCountry = (france == germany)

let countries: Set = [france, germany]
let greetings = [france: "Bonjour", germany: "Gutten Tag"]

// Swift 4.1 adds default implementation in structs for Equatable and Hashable as long as all their properties are Equatable & Hashable. This simplifies the code:
struct NewCountry: Hashable {
    let name: String
    let capital: String
}

// Same situation happened in Swift 4 with enumeration with asociated values:
enum BlogSpot: Hashable {
    case tutorial(String, String)
    case article(String, String)
    
    static func ==(lhs: BlogSpot, rhs: BlogSpot) -> Bool {
        switch (lhs, rhs) {
        case let (.tutorial(lhsTutorialTitle, lhsTutorialAuthor), .tutorial(rhsTutorialTitle, rhsTutorialAuthor)):
            return lhsTutorialTitle == rhsTutorialTitle && lhsTutorialAuthor == rhsTutorialAuthor
        case let(.article(lhsArticleTitle, lhsArticleAuthor), .article(rhsArticleTitle, rhsArticleAuthor)):
            return lhsArticleTitle == rhsArticleTitle && lhsArticleAuthor == rhsArticleAuthor
        default:
            return false
        }
    }
    
    var hashValue: Int {
        switch self {
        case let .tutorial(tutorialTitle, tutorialAuthor):
            return tutorialTitle.hashValue ^ tutorialAuthor.hashValue &* 16777619
        case let .article(articleTitle, articleAuthor):
            return articleTitle.hashValue ^ articleAuthor.hashValue &* 16777619
        }
    }
}

// this allowed to compare blog spots and use them in sets and dicts:
let swift3Article = BlogSpot.article("Whats new in 3.1", "Cosmin")
let swift4Article = BlogSpot.article("new n 4.1", "Cosmin")
let sameArticle = (swift3Article == swift4Article)

let swiftArticleSet: Set = [swift3Article, swift4Article]
let swiftArticleDict = [swift3Article: "Swift 3.1 article", swift4Article: "Swift 4.1 Art."]


// Again, Swift 4.1 reduces the complexity of that code to this:
enum NewBlogSpot: Hashable {
    case tutorial(String, String)
    case article(String, String)
}

//:## Hashable Index Types
// In Swift 4: Key paths may have used subscripts if the subscript parameter's type was Hashable. This enabled them to work with arrays of double for example:
let swiftVersions = [3, 2, 4, 4.1]
let path = \[Double].[swiftVersions.count - 1]
let latestVersion = swiftVersions[keyPath: path]

// Swift 4.1 adds Hashable conformance to all index types in the standard library (SE-0188):
let me = "Cosmin"
let newPath = \String.[me.startIndex]
let firstChar = me[keyPath: newPath]

//:## Recursive Constraints on Associated Types in Protocols

// Swift 4 didn't support defining recursive constraints on associated types in protocols:
protocol Phone {
    associatedtype Version
    associatedtype SmartPhone
}

class IPhone: Phone {
    typealias Version = String
    typealias SmartPhone = IPhone
}

// In this example it might be useful to constrain the SmartPhone associated type to Phone. This is now possible in Swift 4.1 (SE-0157):
protocol NewPhone {
    associatedtype Version
    associatedtype SmartPhone: NewPhone where SmartPhone.Version == Version, SmartPhone.SmartPhone == SmartPhone
}
// We use 'where' to constrain both Version and SmartPhone to be the same as the phone's.

//: ## Weak and Unowned References in Protocols
// Swift 4 supported weak and unowned for protocol properties:
class Key {}
class Pitch {}

protocol Tune {
    unowned var key: Key { get set }
    weak var pitch: Pitch? { get set }
}

class Instrument: Tune {
    var key: Key
    var pitch: Pitch?
    
    init(key: Key, pitch: Pitch?) {
        self.key = key
        self.pitch = pitch
    }
}

// But both weak and unowned are practically meaningless if defined within the protocol so in Swift 4.1 this is removed and you get a warning otherwise SE-0186:
protocol NewTune {
    var key: Key { get set }
    var pitch: Pitch? { get set }
}

//: ## Indexes Distances in Collections
// Swift 4 used IndexDistances to declare the number of elements in a collection:
func typeOfCollection<C: Collection>(_ collection: C) -> (String, C.IndexDistance) {
    let collectionType: String
    
    switch collection.count {
    case 0...100:
        collectionType = "small"
    case 101...1000:
        collectionType = "medium"
    case 1001...:
        collectionType = "big"
    default:
        collectionType = "unknown"
    }
    
    return (collectionType, collection.count)
}

// typeOfCollection returned tuple could be used for any kind of collections: array, dictionaries, sets; for example:
typeOfCollection(1...800) // ("medium", 800)
typeOfCollection(greetings) // ("small", 2)

// the function's return type could be improved by constraining IndexDistance to Int with a where clause:
func typeOfCollection2<C: Collection>(_ collection: C) -> (String, Int) where C.IndexDistance == Int {
    // same code as above
    return ("dummy", 3)
}

// Swift 4.1 replaces IndexDistance with Int in the standard library, so you don't need a where clause in this case [SE-0191]:
func typeOfCollection41<C: Collection>(_ collection: C) -> (String, Int) {
    //same code as above typeOfCollection
    return ("avoidCompileError", 1)
}

//: ## Structure Initializers in Modules
// Adding properties to public structs could lead to source-breaking changes in Swift 4. This change makes structs behave like classes: cross-module initializers must be convenience initializers in Swift 4.1 [SE-0189].


//: ## Platform Settings and Build Configuration Updates
// Swift 4.1 add some much-needed platform and build features for code testing:

//: ### Build Imports
// In Swift 4 you tested if a module was available on a certain platform by checkoung the operating system itself; for example:
#if os(iOS) || os(tvOS)
    import UIKit
    print("UIKit is available on this platform")
#else
    print("UIKit is NOT available on this platform")
#endif

// Swift 4.1 further simplifies this by letting you check for the module itself instead, [SE-0075]:
#if canImport(UIKit)
    print("UIKit available")
#endif

//: ### Target Environments
// In Swift 4 the most well-known way to check wether you were running on a simulator or a physical dvice was by checking the architecture and os:
#if ( arch(i386) || arch(x86_64) ) && ( os(iOS) || os(tvOS) || os(watchOS) )
    print("Testing in simulator")
#else
    print("Testing on real device")
#endif

// Swift 4.1 makes this check more straightforward [SE-0190]:
#if targetEnvironment(simulator)
    print("running in simulator")
#endif

//: ## Miscellaneous
//: ### Compacting Sequences
// In Swift 4, it was fairly common to use flatMap(_:) to filter out nil values from a sequence:
let pets = ["Sclip", nil, "Nori", nil]
let petNames = pets.flatMap { $0 }

// but flatMap(_:) was overloaded in various ways and, in that specific scenario the naming was not very descriptive.
// For that reason Swift 4.1 renames flatMap(_:) to compactMap(_:) to make its meaning clearer and unique [SE-0187]:
let petNames41 = pets.compactMap { $0 }

//: ### Unsafe Pointers
// Swift 4 used temporary unsafe mutable pointers to create and mutate unsafe mutable buffer pointers:
let buffer = UnsafeMutableBufferPointer<Int>(start: UnsafeMutablePointer<Int>.allocate(capacity: 10), count: 10)
let mutableBuffer = UnsafeMutableBufferPointer(start: UnsafeMutablePointer(mutating:buffer.baseAddress), count: buffer.count)

// Swift 4.1 lets you work with unsafe mutable buffer pointers directly [SE-0184]:
let buffer41 = UnsafeMutableBufferPointer<Int>.allocate(capacity: 10)
let mutableBuffer41 = UnsafeMutableBufferPointer(mutating: UnsafeBufferPointer(buffer41))

//: ### New Playground features
// Swift 4 allowed you to customize type descriptions in Xcode paygrounds:
class Tutorial {}
extension Tutorial: CustomPlaygroundQuickLookable {
    var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text("raywenderlich tutorials")
    }
}
let tutorial = Tutorial()

// In Swift 4.1 the description's type is no longer limited to: PlaygroundQuickLook:
extension Tutorial: CustomPlaygroundDisplayConvertible {
    var playgroundDescription: Any {
        return "raywenderlich tutorial 4.1"
    }
}
// We can implement CustomPlaygroundDisplayConvertible. The description's type is Any now, so we can return anything from playgroundDescription. [SE-0198]

//: [Next](@next)


