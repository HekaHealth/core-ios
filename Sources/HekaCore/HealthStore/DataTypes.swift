//
//  DataTypes.swift
//

import HealthKit

class HealthKitDataTypes {

  var dataTypesDict: [String: HKSampleType] = [:]
  var healthDataTypes = [HKSampleType]()
  var heartRateEventTypes = Set<HKSampleType>()
  var headacheType = Set<HKSampleType>()
  var workoutActivityTypeMap: [String: HKWorkoutActivityType] = [:]
  var dataTypeToUnit: [String: HKUnit] = [:]

  let GRAM = "GRAM"
  let KILOGRAM = "KILOGRAM"
  let OUNCE = "OUNCE"
  let POUND = "POUND"
  let STONE = "STONE"
  let METER = "METER"
  let INCH = "INCH"
  let FOOT = "FOOT"
  let YARD = "YARD"
  let MILE = "MILE"
  let LITER = "LITER"
  let MILLILITER = "MILLILITER"
  let FLUID_OUNCE_US = "FLUID_OUNCE_US"
  let FLUID_OUNCE_IMPERIAL = "FLUID_OUNCE_IMPERIAL"
  let CUP_US = "CUP_US"
  let CUP_IMPERIAL = "CUP_IMPERIAL"
  let PINT_US = "PINT_US"
  let PINT_IMPERIAL = "PINT_IMPERIAL"
  let PASCAL = "PASCAL"
  let MILLIMETER_OF_MERCURY = "MILLIMETER_OF_MERCURY"
  let INCHES_OF_MERCURY = "INCHES_OF_MERCURY"
  let CENTIMETER_OF_WATER = "CENTIMETER_OF_WATER"
  let ATMOSPHERE = "ATMOSPHERE"
  let DECIBEL_A_WEIGHTED_SOUND_PRESSURE_LEVEL = "DECIBEL_A_WEIGHTED_SOUND_PRESSURE_LEVEL"
  let SECOND = "SECOND"
  let MILLISECOND = "MILLISECOND"
  let MINUTE = "MINUTE"
  let HOUR = "HOUR"
  let DAY = "DAY"
  let JOULE = "JOULE"
  let KILOCALORIE = "KILOCALORIE"
  let LARGE_CALORIE = "LARGE_CALORIE"
  let SMALL_CALORIE = "SMALL_CALORIE"
  let DEGREE_CELSIUS = "DEGREE_CELSIUS"
  let DEGREE_FAHRENHEIT = "DEGREE_FAHRENHEIT"
  let KELVIN = "KELVIN"
  let DECIBEL_HEARING_LEVEL = "DECIBEL_HEARING_LEVEL"
  let HERTZ = "HERTZ"
  let SIEMEN = "SIEMEN"
  let VOLT = "VOLT"
  let INTERNATIONAL_UNIT = "INTERNATIONAL_UNIT"
  let COUNT = "COUNT"
  let PERCENT = "PERCENT"
  let BEATS_PER_MINUTE = "BEATS_PER_MINUTE"
  let MILLIGRAM_PER_DECILITER = "MILLIGRAM_PER_DECILITER"
  let UNKNOWN_UNIT = "UNKNOWN_UNIT"
  let NO_UNIT = "NO_UNIT"

  // Health Data Type Keys
  let ACTIVE_ENERGY_BURNED = "ACTIVE_ENERGY_BURNED"
  let AUDIOGRAM = "AUDIOGRAM"
  let BASAL_ENERGY_BURNED = "BASAL_ENERGY_BURNED"
  let BLOOD_GLUCOSE = "BLOOD_GLUCOSE"
  let BLOOD_OXYGEN = "BLOOD_OXYGEN"
  let BLOOD_PRESSURE_DIASTOLIC = "BLOOD_PRESSURE_DIASTOLIC"
  let BLOOD_PRESSURE_SYSTOLIC = "BLOOD_PRESSURE_SYSTOLIC"
  let BODY_FAT_PERCENTAGE = "BODY_FAT_PERCENTAGE"
  let BODY_MASS_INDEX = "BODY_MASS_INDEX"
  let BODY_TEMPERATURE = "BODY_TEMPERATURE"
  let DIETARY_CARBS_CONSUMED = "DIETARY_CARBS_CONSUMED"
  let DIETARY_ENERGY_CONSUMED = "DIETARY_ENERGY_CONSUMED"
  let DIETARY_FATS_CONSUMED = "DIETARY_FATS_CONSUMED"
  let DIETARY_PROTEIN_CONSUMED = "DIETARY_PROTEIN_CONSUMED"
  let ELECTRODERMAL_ACTIVITY = "ELECTRODERMAL_ACTIVITY"
  let FORCED_EXPIRATORY_VOLUME = "FORCED_EXPIRATORY_VOLUME"
  let HEART_RATE = "HEART_RATE"
  let HEART_RATE_VARIABILITY_SDNN = "HEART_RATE_VARIABILITY_SDNN"
  let HEIGHT = "HEIGHT"
  let HIGH_HEART_RATE_EVENT = "HIGH_HEART_RATE_EVENT"
  let IRREGULAR_HEART_RATE_EVENT = "IRREGULAR_HEART_RATE_EVENT"
  let LOW_HEART_RATE_EVENT = "LOW_HEART_RATE_EVENT"
  let RESTING_HEART_RATE = "RESTING_HEART_RATE"
  let STEPS = "STEPS"
  let WAIST_CIRCUMFERENCE = "WAIST_CIRCUMFERENCE"
  let WALKING_HEART_RATE = "WALKING_HEART_RATE"
  let WEIGHT = "WEIGHT"
  let DISTANCE_WALKING_RUNNING = "DISTANCE_WALKING_RUNNING"
  let FLIGHTS_CLIMBED = "FLIGHTS_CLIMBED"
  let WATER = "WATER"
  let MINDFULNESS = "MINDFULNESS"
  let SLEEP_IN_BED = "SLEEP_IN_BED"
  let SLEEP_ASLEEP = "SLEEP_ASLEEP"
  let SLEEP_AWAKE = "SLEEP_AWAKE"
  let EXERCISE_TIME = "EXERCISE_TIME"
  let WORKOUT = "WORKOUT"
  let HEADACHE_UNSPECIFIED = "HEADACHE_UNSPECIFIED"
  let HEADACHE_NOT_PRESENT = "HEADACHE_NOT_PRESENT"
  let HEADACHE_MILD = "HEADACHE_MILD"
  let HEADACHE_MODERATE = "HEADACHE_MODERATE"
  let HEADACHE_SEVERE = "HEADACHE_SEVERE"
  let MENSTRUAL_FLOW = "MENSTRUAL_FLOW"
  let SLEEP_ANALYSIS = "SLEEP_ANALYSIS"

  func initDataTypesDict() {
    // Set up iOS 13 specific types (ordinary health data types)
    if #available(iOS 13.0, *) {
      dataTypesDict[ACTIVE_ENERGY_BURNED] = HKSampleType.quantityType(
        forIdentifier: .activeEnergyBurned)!
      dataTypesDict[AUDIOGRAM] = HKSampleType.audiogramSampleType()
      dataTypesDict[BASAL_ENERGY_BURNED] = HKSampleType.quantityType(
        forIdentifier: .basalEnergyBurned)!
      dataTypesDict[BLOOD_GLUCOSE] = HKSampleType.quantityType(forIdentifier: .bloodGlucose)!
      dataTypesDict[BLOOD_OXYGEN] = HKSampleType.quantityType(forIdentifier: .oxygenSaturation)!
      dataTypesDict[BLOOD_PRESSURE_DIASTOLIC] = HKSampleType.quantityType(
        forIdentifier: .bloodPressureDiastolic)!
      dataTypesDict[BLOOD_PRESSURE_SYSTOLIC] = HKSampleType.quantityType(
        forIdentifier: .bloodPressureSystolic)!
      dataTypesDict[BODY_FAT_PERCENTAGE] = HKSampleType.quantityType(
        forIdentifier: .bodyFatPercentage)!
      dataTypesDict[BODY_MASS_INDEX] = HKSampleType.quantityType(forIdentifier: .bodyMassIndex)!
      dataTypesDict[BODY_TEMPERATURE] = HKSampleType.quantityType(forIdentifier: .bodyTemperature)!
      dataTypesDict[DIETARY_CARBS_CONSUMED] = HKSampleType.quantityType(
        forIdentifier: .dietaryCarbohydrates)!
      dataTypesDict[DIETARY_ENERGY_CONSUMED] = HKSampleType.quantityType(
        forIdentifier: .dietaryEnergyConsumed)!
      dataTypesDict[DIETARY_FATS_CONSUMED] = HKSampleType.quantityType(
        forIdentifier: .dietaryFatTotal)!
      dataTypesDict[DIETARY_PROTEIN_CONSUMED] = HKSampleType.quantityType(
        forIdentifier: .dietaryProtein)!
      dataTypesDict[ELECTRODERMAL_ACTIVITY] = HKSampleType.quantityType(
        forIdentifier: .electrodermalActivity)!
      dataTypesDict[FORCED_EXPIRATORY_VOLUME] = HKSampleType.quantityType(
        forIdentifier: .forcedExpiratoryVolume1)!
      dataTypesDict[HEART_RATE] = HKSampleType.quantityType(forIdentifier: .heartRate)!
      dataTypesDict[HEART_RATE_VARIABILITY_SDNN] = HKSampleType.quantityType(
        forIdentifier: .heartRateVariabilitySDNN)!
      dataTypesDict[HEIGHT] = HKSampleType.quantityType(forIdentifier: .height)!
      dataTypesDict[RESTING_HEART_RATE] = HKSampleType.quantityType(
        forIdentifier: .restingHeartRate)!
      dataTypesDict[STEPS] = HKSampleType.quantityType(forIdentifier: .stepCount)!
      dataTypesDict[WAIST_CIRCUMFERENCE] = HKSampleType.quantityType(
        forIdentifier: .waistCircumference)!
      dataTypesDict[WALKING_HEART_RATE] = HKSampleType.quantityType(
        forIdentifier: .walkingHeartRateAverage)!
      dataTypesDict[WEIGHT] = HKSampleType.quantityType(forIdentifier: .bodyMass)!
      dataTypesDict[DISTANCE_WALKING_RUNNING] = HKSampleType.quantityType(
        forIdentifier: .distanceWalkingRunning)!
      dataTypesDict[FLIGHTS_CLIMBED] = HKSampleType.quantityType(forIdentifier: .flightsClimbed)!
      dataTypesDict[WATER] = HKSampleType.quantityType(forIdentifier: .dietaryWater)!
      dataTypesDict[MINDFULNESS] = HKSampleType.categoryType(forIdentifier: .mindfulSession)!
      dataTypesDict[SLEEP_IN_BED] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
      dataTypesDict[SLEEP_ASLEEP] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
      dataTypesDict[SLEEP_AWAKE] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
      dataTypesDict[EXERCISE_TIME] = HKSampleType.quantityType(forIdentifier: .appleExerciseTime)!
      dataTypesDict[WORKOUT] = HKSampleType.workoutType()
      dataTypesDict[MENSTRUAL_FLOW] = HKSampleType.categoryType(forIdentifier: .menstrualFlow)!
      dataTypesDict[SLEEP_ANALYSIS] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!

      healthDataTypes = Array(dataTypesDict.values)
    }
    // Set up heart rate data types specific to the apple watch, requires iOS 12
    if #available(iOS 12.2, *) {
      dataTypesDict[HIGH_HEART_RATE_EVENT] = HKSampleType.categoryType(
        forIdentifier: .highHeartRateEvent)!
      dataTypesDict[LOW_HEART_RATE_EVENT] = HKSampleType.categoryType(
        forIdentifier: .lowHeartRateEvent)!
      dataTypesDict[IRREGULAR_HEART_RATE_EVENT] = HKSampleType.categoryType(
        forIdentifier: .irregularHeartRhythmEvent)!

      heartRateEventTypes = Set([
        HKSampleType.categoryType(forIdentifier: .highHeartRateEvent)!,
        HKSampleType.categoryType(forIdentifier: .lowHeartRateEvent)!,
        HKSampleType.categoryType(forIdentifier: .irregularHeartRhythmEvent)!,
      ])
    }

    if #available(iOS 13.6, *) {
      dataTypesDict[HEADACHE_UNSPECIFIED] = HKSampleType.categoryType(forIdentifier: .headache)!
      dataTypesDict[HEADACHE_NOT_PRESENT] = HKSampleType.categoryType(forIdentifier: .headache)!
      dataTypesDict[HEADACHE_MILD] = HKSampleType.categoryType(forIdentifier: .headache)!
      dataTypesDict[HEADACHE_MODERATE] = HKSampleType.categoryType(forIdentifier: .headache)!
      dataTypesDict[HEADACHE_SEVERE] = HKSampleType.categoryType(forIdentifier: .headache)!

      headacheType = Set([
        HKSampleType.categoryType(forIdentifier: .headache)!
      ])
    }
  }

  func initDataTypeToUnit() {
    dataTypeToUnit[ACTIVE_ENERGY_BURNED] = HKUnit.kilocalorie()
    dataTypeToUnit[BASAL_ENERGY_BURNED] = HKUnit.kilocalorie()
    dataTypeToUnit[BLOOD_GLUCOSE] = HKUnit.init(from: "mg/dL")
    dataTypeToUnit[BLOOD_OXYGEN] = HKUnit.percent()
    dataTypeToUnit[BLOOD_PRESSURE_DIASTOLIC] = HKUnit.millimeterOfMercury()
    dataTypeToUnit[BLOOD_PRESSURE_SYSTOLIC] = HKUnit.millimeterOfMercury()
    dataTypeToUnit[BODY_FAT_PERCENTAGE] = HKUnit.percent()
    dataTypeToUnit[BODY_MASS_INDEX] = HKUnit.init(from: "")
    dataTypeToUnit[BODY_TEMPERATURE] = HKUnit.degreeCelsius()
    dataTypeToUnit[DIETARY_CARBS_CONSUMED] = HKUnit.gram()
    dataTypeToUnit[DIETARY_ENERGY_CONSUMED] = HKUnit.kilocalorie()
    dataTypeToUnit[DIETARY_FATS_CONSUMED] = HKUnit.gram()
    dataTypeToUnit[DIETARY_PROTEIN_CONSUMED] = HKUnit.gram()
    dataTypeToUnit[ELECTRODERMAL_ACTIVITY] = HKUnit.siemen()
    dataTypeToUnit[FORCED_EXPIRATORY_VOLUME] = HKUnit.liter()
    dataTypeToUnit[HEART_RATE] = HKUnit.init(from: "count/min")
    dataTypeToUnit[HEIGHT] = HKUnit.meter()
    dataTypeToUnit[RESTING_HEART_RATE] = HKUnit.init(from: "count/min")
    dataTypeToUnit[STEPS] = HKUnit.count()
    dataTypeToUnit[WAIST_CIRCUMFERENCE] = HKUnit.meter()
    dataTypeToUnit[WALKING_HEART_RATE] = HKUnit.init(from: "count/min")
    dataTypeToUnit[WEIGHT] = HKUnit.gramUnit(with: .kilo)
    dataTypeToUnit[DISTANCE_WALKING_RUNNING] = HKUnit.meter()
    dataTypeToUnit[FLIGHTS_CLIMBED] = HKUnit.count()
    dataTypeToUnit[WATER] = HKUnit.liter()
    dataTypeToUnit[SLEEP_IN_BED] = HKUnit.minute()
    dataTypeToUnit[SLEEP_ASLEEP] = HKUnit.minute()
    dataTypeToUnit[SLEEP_AWAKE] = HKUnit.minute()
    dataTypeToUnit[MINDFULNESS] = HKUnit.minute()
    dataTypeToUnit[EXERCISE_TIME] = HKUnit.minute()
    dataTypeToUnit[WORKOUT] = HKUnit.init(from: "")
    dataTypeToUnit[HEADACHE_NOT_PRESENT] = HKUnit.minute()
    dataTypeToUnit[HEADACHE_MILD] = HKUnit.minute()
    dataTypeToUnit[HEADACHE_MODERATE] = HKUnit.minute()
    dataTypeToUnit[HEADACHE_SEVERE] = HKUnit.minute()
    dataTypeToUnit[HEADACHE_UNSPECIFIED] = HKUnit.minute()
    dataTypeToUnit[HIGH_HEART_RATE_EVENT] = HKUnit.init(from: "")
    dataTypeToUnit[LOW_HEART_RATE_EVENT] = HKUnit.init(from: "")
    dataTypeToUnit[IRREGULAR_HEART_RATE_EVENT] = HKUnit.init(from: "")
    dataTypeToUnit[HEART_RATE_VARIABILITY_SDNN] = HKUnit.secondUnit(with: .milli)

    if #available(iOS 13.6, *) {
      dataTypeToUnit[AUDIOGRAM] = HKUnit.decibelHearingLevel()
    }
  }

  func initWorkoutTypes() {
    // Initialize workout types
    workoutActivityTypeMap["ARCHERY"] = .archery
    workoutActivityTypeMap["BOWLING"] = .bowling
    workoutActivityTypeMap["FENCING"] = .fencing
    workoutActivityTypeMap["GYMNASTICS"] = .gymnastics
    workoutActivityTypeMap["TRACK_AND_FIELD"] = .trackAndField
    workoutActivityTypeMap["AMERICAN_FOOTBALL"] = .americanFootball
    workoutActivityTypeMap["AUSTRALIAN_FOOTBALL"] = .australianFootball
    workoutActivityTypeMap["BASEBALL"] = .baseball
    workoutActivityTypeMap["BASKETBALL"] = .basketball
    workoutActivityTypeMap["CRICKET"] = .cricket
    workoutActivityTypeMap["HANDBALL"] = .handball
    workoutActivityTypeMap["HOCKEY"] = .hockey
    workoutActivityTypeMap["LACROSSE"] = .lacrosse
    workoutActivityTypeMap["RUGBY"] = .rugby
    workoutActivityTypeMap["SOCCER"] = .soccer
    workoutActivityTypeMap["SOFTBALL"] = .softball
    workoutActivityTypeMap["VOLLEYBALL"] = .volleyball
    workoutActivityTypeMap["PREPARATION_AND_RECOVERY"] = .preparationAndRecovery
    workoutActivityTypeMap["FLEXIBILITY"] = .flexibility
    workoutActivityTypeMap["WALKING"] = .walking
    workoutActivityTypeMap["RUNNING"] = .running
    workoutActivityTypeMap["RUNNING_JOGGING"] = .running  // Supported due to combining with Android naming
    workoutActivityTypeMap["RUNNING_SAND"] = .running  // Supported due to combining with Android naming
    workoutActivityTypeMap["RUNNING_TREADMILL"] = .running  // Supported due to combining with Android naming
    workoutActivityTypeMap["WHEELCHAIR_WALK_PACE"] = .wheelchairWalkPace
    workoutActivityTypeMap["WHEELCHAIR_RUN_PACE"] = .wheelchairRunPace
    workoutActivityTypeMap["BIKING"] = .cycling
    workoutActivityTypeMap["HAND_CYCLING"] = .handCycling
    workoutActivityTypeMap["CORE_TRAINING"] = .coreTraining
    workoutActivityTypeMap["ELLIPTICAL"] = .elliptical
    workoutActivityTypeMap["FUNCTIONAL_STRENGTH_TRAINING"] = .functionalStrengthTraining
    workoutActivityTypeMap["TRADITIONAL_STRENGTH_TRAINING"] = .traditionalStrengthTraining
    workoutActivityTypeMap["CROSS_TRAINING"] = .crossTraining
    workoutActivityTypeMap["MIXED_CARDIO"] = .mixedCardio
    workoutActivityTypeMap["HIGH_INTENSITY_INTERVAL_TRAINING"] = .highIntensityIntervalTraining
    workoutActivityTypeMap["JUMP_ROPE"] = .jumpRope
    workoutActivityTypeMap["STAIR_CLIMBING"] = .stairClimbing
    workoutActivityTypeMap["STAIRS"] = .stairs
    workoutActivityTypeMap["STEP_TRAINING"] = .stepTraining
    workoutActivityTypeMap["BARRE"] = .barre
    workoutActivityTypeMap["YOGA"] = .yoga
    workoutActivityTypeMap["MIND_AND_BODY"] = .mindAndBody
    workoutActivityTypeMap["PILATES"] = .pilates
    workoutActivityTypeMap["BADMINTON"] = .badminton
    workoutActivityTypeMap["RACQUETBALL"] = .racquetball
    workoutActivityTypeMap["SQUASH"] = .squash
    workoutActivityTypeMap["TABLE_TENNIS"] = .tableTennis
    workoutActivityTypeMap["TENNIS"] = .tennis
    workoutActivityTypeMap["CLIMBING"] = .climbing
    workoutActivityTypeMap["ROCK_CLIMBING"] = .climbing  // Supported due to combining with Android naming
    workoutActivityTypeMap["EQUESTRIAN_SPORTS"] = .equestrianSports
    workoutActivityTypeMap["FISHING"] = .fishing
    workoutActivityTypeMap["GOLF"] = .golf
    workoutActivityTypeMap["HIKING"] = .hiking
    workoutActivityTypeMap["HUNTING"] = .hunting
    workoutActivityTypeMap["PLAY"] = .play
    workoutActivityTypeMap["CROSS_COUNTRY_SKIING"] = .crossCountrySkiing
    workoutActivityTypeMap["CURLING"] = .curling
    workoutActivityTypeMap["DOWNHILL_SKIING"] = .downhillSkiing
    workoutActivityTypeMap["SNOW_SPORTS"] = .snowSports
    workoutActivityTypeMap["SNOWBOARDING"] = .snowboarding
    workoutActivityTypeMap["SKATING"] = .skatingSports
    workoutActivityTypeMap["SKATING_CROSS,"] = .skatingSports  // Supported due to combining with Android naming
    workoutActivityTypeMap["SKATING_INDOOR,"] = .skatingSports  // Supported due to combining with Android naming
    workoutActivityTypeMap["SKATING_INLINE,"] = .skatingSports  // Supported due to combining with Android naming
    workoutActivityTypeMap["PADDLE_SPORTS"] = .paddleSports
    workoutActivityTypeMap["ROWING"] = .rowing
    workoutActivityTypeMap["SAILING"] = .sailing
    workoutActivityTypeMap["SURFING_SPORTS"] = .surfingSports
    workoutActivityTypeMap["SWIMMING"] = .swimming
    workoutActivityTypeMap["WATER_FITNESS"] = .waterFitness
    workoutActivityTypeMap["WATER_POLO"] = .waterPolo
    workoutActivityTypeMap["WATER_SPORTS"] = .waterSports
    workoutActivityTypeMap["BOXING"] = .boxing
    workoutActivityTypeMap["KICKBOXING"] = .kickboxing
    workoutActivityTypeMap["MARTIAL_ARTS"] = .martialArts
    workoutActivityTypeMap["TAI_CHI"] = .taiChi
    workoutActivityTypeMap["WRESTLING"] = .wrestling
    workoutActivityTypeMap["OTHER"] = .other

    if #available(iOS 13.6, *) {
      workoutActivityTypeMap["DISC_SPORTS"] = .discSports
      workoutActivityTypeMap["FITNESS_GAMING"] = .fitnessGaming
    }
  }
}
