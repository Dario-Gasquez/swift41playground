//: [Previous](@previous)
//: # Conditional Conformance

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


//: ## Conditional Conformance in JSON Parsing
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
} catch {
    print(error.localizedDescription)
}

for studentInfo in studentsInfo {
    print("\(studentInfo.firstName) - \(studentInfo.averageGrade)")
}

//: [Next](@next)
