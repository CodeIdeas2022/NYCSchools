# NYCSchools
NYC high schools browser

Provides the following features
- Fetches NYC High schools directory dated 2017 from https://data.cityofnewyork.us/Education/2017-DOE-High-School-Directory/s3k6-pzi2 through NYC OpenData services 
- Fetches NYC High schools SAT scores dated 2012 from https://data.cityofnewyork.us/Education/2012-SAT-Results/f9bf-2cp4  through NYC OpenData services
- Lists the directory
- Allows sorting of schools based on various criteria like graduation rate, total students, SAT scores, SAT ranking etc
- Displays a school details screen which shows more information about the school

Technologies used
- iOS
- XCode
- Swift Language
- Swift Combine. This is my first attempt at using Combine. Familiar with RxSwift.
- UIKit
- iOS Network API's to fetch schools directory and details

NOTES:
- During sort, if a school has invalid data associated with the sort criteria, its always pushed to the bottom of the list. 
- Schools details screen will only display valid SAT data for the school. In case of invalid data, the data will be shown as "not available"

Additional possibilities
- Instead of displaying schools as a list, the schools can be put on a map since the directory has school location data(latitude and longitude)
- Share data through iOS share feature
- Sort options for search results

Wiki with screenshots
https://github.com/CodeIdeas2022/NYCSchools/wiki/NYC-Schools
