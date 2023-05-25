//
//  ExperienceSchedule.swift
//  More
//
//  Created by Luko Gjenero on 06/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

class ExperienceSchedule: MoreDataObject {

    let id: String = ""
    
    let start: Date?
    let end: Date?
    
    let monday: ExperienceDaySchedule?
    let tuesday: ExperienceDaySchedule?
    let wednesday: ExperienceDaySchedule?
    let thursday: ExperienceDaySchedule?
    let friday: ExperienceDaySchedule?
    let saturday: ExperienceDaySchedule?
    let sunday: ExperienceDaySchedule?

    init(start: Date?,
         end: Date?,
         monday: ExperienceDaySchedule?,
         tuesday: ExperienceDaySchedule?,
         wednesday: ExperienceDaySchedule?,
         thursday: ExperienceDaySchedule?,
         friday: ExperienceDaySchedule?,
         saturday: ExperienceDaySchedule?,
         sunday: ExperienceDaySchedule?) {
        
        self.start = start
        self.end = end
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
    }
    
    func experienceScheduleWithDaySchedules(monday: ExperienceDaySchedule?,
                                            tuesday: ExperienceDaySchedule?,
                                            wednesday: ExperienceDaySchedule?,
                                            thursday: ExperienceDaySchedule?,
                                            friday: ExperienceDaySchedule?,
                                            saturday: ExperienceDaySchedule?,
                                            sunday: ExperienceDaySchedule?) -> ExperienceSchedule {
        
        return ExperienceSchedule(start: start,
                                  end: end,
                                  monday: monday,
                                  tuesday: tuesday,
                                  wednesday: wednesday,
                                  thursday: thursday,
                                  friday: friday,
                                  saturday: saturday,
                                  sunday: sunday)
    }
    
    func experienceScheduleWithStartEnd(start: Date?,
                                        end: Date?) -> ExperienceSchedule {
        
        return ExperienceSchedule(start: start,
                                  end: end,
                                  monday: monday,
                                  tuesday: tuesday,
                                  wednesday: wednesday,
                                  thursday: thursday,
                                  friday: friday,
                                  saturday: saturday,
                                  sunday: sunday)
    }
    
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ExperienceSchedule, rhs: ExperienceSchedule) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Helpers
    
    func isActive() -> Bool {
        let now = Date()
        if isDateInside(now) {
            guard isScheduled() else { return true }
            
            let weekday = Calendar.current.dateComponents([.weekday], from: now).weekday ?? 0
            
            switch weekday {
            case 1: // Sunday
                return isScheduled(now, today: sunday, yesterday: saturday)
            case 2: // Monday
                return isScheduled(now, today: monday, yesterday: sunday)
            case 3: // Tuesday
                return isScheduled(now, today: tuesday, yesterday: monday)
            case 4: // Wednesday
                return isScheduled(now, today: wednesday, yesterday: tuesday)
            case 5: // Thursday
                return isScheduled(now, today: thursday, yesterday: wednesday)
            case 6: // Friday
                return isScheduled(now, today: friday, yesterday: thursday)
            case 7: // Saturday
                return isScheduled(now, today: saturday, yesterday: friday)
            default:
                return false
            }
            
        }
        
        return false
    }
    
    func isDateInside(_ date: Date) -> Bool {
        if let start = start, start > date {
            return false
        }
        if let end = end, end < date {
            return false
        }
        return true
    }
    
    func isScheduled() -> Bool {
        return monday != nil || tuesday != nil || wednesday != nil || thursday != nil || friday != nil || saturday != nil || sunday != nil
    }
    
    func isScheduled(_ date: Date, today: ExperienceDaySchedule?, yesterday: ExperienceDaySchedule?) -> Bool {
        
        // is it in today's schedule
        if let today = today {
            let startOfDay = Calendar.current.startOfDay(for: date)
            let start = startOfDay.addingTimeInterval(today.start)
            let end = startOfDay.addingTimeInterval(today.end)
            if date >= start && date <= end {
                return true
            }
        }
        
        // is it in yesterday's schedule (in case it is overlaping to today)
        if let yesterday = yesterday,
            let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: date) {
            let startOfDay = Calendar.current.startOfDay(for: dayBefore)
            let start = startOfDay.addingTimeInterval(yesterday.start)
            let end = startOfDay.addingTimeInterval(yesterday.end)
            if date >= start && date <= end {
                return true
            }
        }
        
        return false
    }
    
    // JSON
    
    var json: [String: Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "id")
                
                json.removeValue(forKey: "monday")
                json["monday"] = monday?.json
                
                json.removeValue(forKey: "tuesday")
                json["tuesday"] = tuesday?.json
                
                json.removeValue(forKey: "wednesday")
                json["wednesday"] = wednesday?.json
                
                json.removeValue(forKey: "thursday")
                json["thursday"] = thursday?.json
                
                json.removeValue(forKey: "friday")
                json["friday"] = friday?.json
                
                json.removeValue(forKey: "saturday")
                json["saturday"] = saturday?.json
                
                json.removeValue(forKey: "sunday")
                json["sunday"] = sunday?.json
                
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String: Any]) -> ExperienceSchedule? {
        
        
        let monday: [String: Any]? = json["monday"] as? [String: Any]
        let tuesday: [String: Any]? = json["tuesday"] as? [String: Any]
        let wednesday: [String: Any]? = json["wednesday"] as? [String: Any]
        let thursday: [String: Any]? = json["thursday"] as? [String: Any]
        let friday: [String: Any]? = json["friday"] as? [String: Any]
        let saturday: [String: Any]? = json["saturday"] as? [String: Any]
        let sunday: [String: Any]? = json["sunday"] as? [String: Any]
        
        var rectifiedJson = json
        rectifiedJson.removeValue(forKey: "monday")
        rectifiedJson.removeValue(forKey: "tuesday")
        rectifiedJson.removeValue(forKey: "wednesday")
        rectifiedJson.removeValue(forKey: "thursday")
        rectifiedJson.removeValue(forKey: "friday")
        rectifiedJson.removeValue(forKey: "saturday")
        rectifiedJson.removeValue(forKey: "sunday")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: rectifiedJson, options: []),
            var daySchedule = try? JSONDecoder().decode(ExperienceSchedule.self, from: jsonData) {
            
            let mondayObj = ExperienceDaySchedule.fromJson(monday ?? [:])
            let tuesdayObj = ExperienceDaySchedule.fromJson(tuesday ?? [:])
            let wednesdayObj = ExperienceDaySchedule.fromJson(wednesday ?? [:])
            let thursdayObj = ExperienceDaySchedule.fromJson(thursday ?? [:])
            let fridayObj = ExperienceDaySchedule.fromJson(friday ?? [:])
            let saturdayObj = ExperienceDaySchedule.fromJson(saturday ?? [:])
            let sundayObj = ExperienceDaySchedule.fromJson(sunday ?? [:])
            
            daySchedule = daySchedule.experienceScheduleWithDaySchedules(
                monday: mondayObj,
                tuesday: tuesdayObj,
                wednesday: wednesdayObj,
                thursday: thursdayObj,
                friday: fridayObj,
                saturday: saturdayObj,
                sunday: sundayObj)
            
            return daySchedule
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ExperienceSchedule? {
        if let json = snapshot.data() {
            return ExperienceSchedule.fromJson(json)
        }
        return nil
    }
    

}

class ExperienceDaySchedule: Codable, Hashable, MoreDataObject {
    
    let id: String = ""
    let start: TimeInterval
    let end: TimeInterval
    
    init(start: TimeInterval,
         end: TimeInterval) {
        
        self.start = start
        self.end = end
    }
    
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ExperienceDaySchedule, rhs: ExperienceDaySchedule) -> Bool {
        return lhs.id == rhs.id
    }
    
    // JSON
    
    var json: [String: Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "id")
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String: Any]) -> ExperienceDaySchedule? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let daySchedule = try? JSONDecoder().decode(ExperienceDaySchedule.self, from: jsonData) {
            return daySchedule
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ExperienceDaySchedule? {
        if let json = snapshot.data() {
            return ExperienceDaySchedule.fromJson(json)
        }
        return nil
    }
    
}
