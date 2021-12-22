import UIKit
import Foundation

protocol Parkable {
    var plate: String { get }
    var type: VehicleType { get }
    var checkInTime: Date { get }
    var discountCard: String? { get }
    var parkedTime: Int { get }
}

enum VehicleType {
    case car, moto, miniBus, bus
    
    var hourFee: Int {
        switch self {
        case .car:
            return 20
        case .moto:
            return 15
        case .miniBus:
            return 25
        case .bus:
            return 30
        }
    }
}

struct Vehicle: Parkable, Hashable {
    let plate: String
    let type: VehicleType
    let checkInTime: Date
    let discountCard: String?
    
    var parkedTime: Int {
        return Calendar.current.dateComponents([.minute], from: checkInTime, to: Date()).minute ?? 0
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(plate)
    }
    
    static func ==(lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.plate == rhs.plate
    }
}

struct Parking {
    private var vehicles: Set<Vehicle> = []
    var listVehiclesCheckout: [(String, Double)] = []
    private let maxVehiclesAllow: Int = 20
    
    mutating func checkInVehicle(_ vehicle: Vehicle, onFinish: (Bool) -> Void) {
        guard vehicles.count < maxVehiclesAllow, vehicles.insert(vehicle).inserted else {
            onFinish(false)
            return
        }
        onFinish(true)
    }
    
    mutating func checkOutVehicle (_ plate: String, onSuccess: (Double, String) -> (), onError: (String) -> ()){
        guard let vehicle = vehicles.first(where: {$0.plate == plate}) else {
            onError("Sorry, the check-out failed")
            return
        }
        
        var hasDiscount: Bool = false
        let discount = vehicle.discountCard
        if discount != nil { hasDiscount = true }
        let fee = calcFee(type: vehicle.type, parkedTime: Double(vehicle.parkedTime), discountCard: hasDiscount)
        
        // SAVE ADMIN INFO
        listVehiclesCheckout.append((plate, fee.0))
        
        // VEHICLE REMOVE
        vehicles.remove(vehicle)
        
        onSuccess(fee.0, fee.1)
    }
    
    //CALC FEE
    
    func calcFee(type: VehicleType, parkedTime: Double, discountCard: Bool) -> (Double, String) {
        let initial = Double(type.hourFee)
        var extraTime: Double?
        var extraTimePrice: Double?
        var discount: Double = 0
        
        if parkedTime > 120 {
            extraTime = parkedTime - 120
            extraTimePrice = (ceil(extraTime ?? 0 / 15)) * 5
        }
        
        var fee = initial + (extraTimePrice ?? 0)
        if discountCard {
            discount = fee - fee * 0.85
            fee = fee * 0.85
        }
        
        guard let hasExtra = extraTime, let extraPrice = extraTimePrice else{
            return (fee, "Your fee: $\(fee) details: \n Basic fee: $\(initial) \n Discount: \(discount) \n Come back soon")
        }
        
        return (fee, "Your fee: $\(fee) details: \n Basic fee: $\(initial) \n Extra fee (\(hasExtra) minutes): $\(extraPrice) \n Discount: \(discount) \n Come back soon"  )
    }
    
    func adminStatus(){
        var Counter: Int = 0
        var Profits: Double = 0
        
        for listVehiclesCheckout in listVehiclesCheckout {
            Counter += 1
            Profits += listVehiclesCheckout.1
        }
        
        print("\(Counter) vehicles have checked out and have earnings of \(Profits)")
    }
    
    func listVehicles(){
        print("Parked Vehicles")
        for vehicle in vehicles {
            print(vehicle.plate)
        }
    }
    
}

var alkeParking = Parking()

let vehiclesTest =  [
                        Vehicle(plate: "AA111AA", type:
                        VehicleType.car, checkInTime: Date(), discountCard:
                        "DISCOUNT_CARD_001"),
                        Vehicle(plate: "B222BBB", type:
                        VehicleType.moto, checkInTime: Date(), discountCard: nil),
                        Vehicle(plate: "CC333CC", type:
                        VehicleType.miniBus, checkInTime: Date(), discountCard:
                        nil),
                        Vehicle(plate: "DD444DD", type:
                        VehicleType.bus, checkInTime: Date(), discountCard:
                        "DISCOUNT_CARD_002"),
                        Vehicle(plate: "AA111BB", type:
                        VehicleType.car, checkInTime: Date(), discountCard:
                        "DISCOUNT_CARD_003"),
                        Vehicle(plate: "B222CCC", type:
                         VehicleType.moto, checkInTime: Date(), discountCard:
                        "DISCOUNT_CARD_004"),
                        Vehicle(plate: "CC333DD", type:
                        VehicleType.miniBus, checkInTime: Date(), discountCard:
                        nil),
                        Vehicle(plate: "DD444EE", type:
                        VehicleType.bus, checkInTime: Date(), discountCard:
                        "DISCOUNT_CARD_005"),
                        Vehicle(plate: "AA111CC", type:
                        VehicleType.car, checkInTime: Date(), discountCard: nil),
                        Vehicle(plate: "B222DDD", type:
                        VehicleType.moto, checkInTime: Date(), discountCard: nil),
                        Vehicle(plate: "CC333EE", type:
                        VehicleType.miniBus, checkInTime: Date(), discountCard:
                        nil),
                        Vehicle(plate: "DD444GG", type:
                        VehicleType.bus, checkInTime: Date(), discountCard:
                        "DISCOUNT_CARD_006"),
                        Vehicle(plate: "AA111DD", type:
                        VehicleType.car, checkInTime: Date(), discountCard:
                        "DISCOUNT_CARD_007"),
                        Vehicle(plate: "B222EEE", type:
                        VehicleType.moto, checkInTime: Date(), discountCard: nil),
                        Vehicle(plate: "CC333FF", type:
                        VehicleType.miniBus, checkInTime: Date(), discountCard:
                        nil),
                        Vehicle(plate: "EE333FF", type:
                        VehicleType.miniBus, checkInTime: Date(), discountCard:
                        nil),
                        Vehicle(plate: "FF333FF", type:
                        VehicleType.miniBus, checkInTime: Date(), discountCard:
                        nil),
                        Vehicle(plate: "GG333FF", type:
                        VehicleType.miniBus, checkInTime: Date(), discountCard:
                        nil),
                        Vehicle(plate: "HH333FF", type:
                        VehicleType.miniBus, checkInTime: Date(), discountCard:
                        nil),
                        Vehicle(plate: "II333FF", type:
                        VehicleType.miniBus, checkInTime: Date(), discountCard:
                        nil),
                        Vehicle(plate: "JJ333FF", type:
                        VehicleType.miniBus, checkInTime: Date(), discountCard:
                        nil)
                    ]

for vehicle in vehiclesTest {
    alkeParking.checkInVehicle(vehicle) { result in
        if result {
            print("Welcome to AlkeParking!")
        } else {
            print("Sorry, the check-in failed")
        }
    }
}

for idx in 0...10 {
    alkeParking.checkOutVehicle(vehiclesTest[idx].plate) { fee, message in
        print(message)
    } onError: { Error in
        print(Error)
    }
}

alkeParking.listVehicles()
alkeParking.adminStatus()
