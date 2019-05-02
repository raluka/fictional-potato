# Fictional Potato
 Service to get campaigns from external JSON API and detect discrepancies between local and remote state

## Tech stack
Ruby version: 2.6.0

## Setup
- Clone project into local machine
- In terminal, go inside the project and run:
```bash
ruby lib/application.rb
```

## Test
In oder to run test suite, run in terminal:
```bash
rspec spec
```


## Considerations:

- This app is proof of concept for checking discrepancies between remote and local data.
- The implementation is not focused on performance with large amount of data (e.g. it doesn't cover cases like API rate limit,
response pagination, or handling big responses from API / database). 
 - Some of the variables are hardcoded (passed url, local response)
 -  One 3rd status was added to API possible statuses, `:deleted`, to mirror local permitted statuses
 - For easier visualization, the final output of discrepancies is logged in console.

## Design Architecture
### Entry point 
Entry point of the app is `application.rb`  as `Application.run!`
This calls `App::OutOfSyncService.call` with the given url. In case of errors, the app stops, and errors are displayed in terminal.

### Core
 Core of the app is `App::OutOfSyncService` service. This has 4 steps of execution:
  - Get the remote data using `Api::FetchCampaigns` service
  - Get the local data using `Campaign::FetchCampaigns` service
  - Build a collection of new `Item` objects from fetched data
  - Iterate over collection and compare remote and local `Items` `Item` object is responsible to compare with another `item` object
  Any errors will stop the app and, the message will appear on `STDOUT`

### Miscellaneous
 - `Item` class contains a `to_h` method, returning a `Hash`, for easier comparison with another similar object
 - Another option for this comparison could be usage of `Struct`.
 - Implementing `==` will increase complexity, as items to compare usually have different location, either remote, or local
 - Method `display_difference` is used to show the discrepancies between local and remote objects, as for the requirement.
 
### Service output format:
```ruby
      [
        {
          remote_reference: 1,
          discrepancies: {
            description:
              {
                local: 'Description local',
                remote: 'Description remote'
              },
            status: {
              local: 'deleted',
              remote: 'active'
            }
          }
        }
      ]
```
