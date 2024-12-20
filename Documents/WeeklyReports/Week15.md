# Agenda

**Goals:**
- Have Alpha ready by Monday
- Have most of the integration for routing implemented
- More tests written for both front and back-end

**Progress Report:**
- Testing is broken because of dotenv on frontend.

**Plans for next week:**
- Project ready for Presentation with route planning and mapping.

**Questions:**
- dotenv issues with frontend CI integration. What is the best way to handle testing when dotenv is required? Likely an issue with how I am finding environment.

# Contributions

## Chastidy: 
**Goals:**
- ...

**Completed Tasks:** 
- ...

**Issues:** 
- ...

**Plans** 
- ...

## Greg: 
**Goals:**
- Work with Tamara on time/distance matrix endpoint
- Build API endpoint around Tamara's routing function
- Write OpenAPI spec for it so Paul can make the frontend implementation of the router

**Completed Tasks:**
- Finished the search API with Tamara
- Wrote more docs and tests for API so Paul can implement searching on frontend

**Issues:**
- Addresses are not coming through the search API

**Plans:**
- Fix missing addresses bug with Tamara
- Build routing endpoint with Tamara

## Paul: 
**Goals:**
- Refine bar listing page.
- Refine crawl creation page.
- Refine settings page and add login/registration.

**Completed Tasks:**
- Bar listing page complete with distances shown.
- Settings page works with login/registration.

**Issues:**
- Dotenv testing issues.
- Lack of tests overall, but specifically for bar listing page and settings right now.
- Crawl creation nonexistant.

**Plans:**
- Crawl creation completed.
- Mapping route on an actual map.

## Tamara:
**Goals:**
- Further optimize location filtering algorithms.
- Improve establishment type classification.
**Completed Tasks:**
- Working on using ORS matrix API to calculate travel times between all bars

**Issues:**
- not done yet 

**Plans:**
- have final product give directions between bars, display total distance and duration, coordinates/address for mapping, and etails about each bar
