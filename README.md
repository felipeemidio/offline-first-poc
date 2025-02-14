# Offline-First PoC Note App

This project aims to be a didatic approach for an Offline-first app. It support the learnings taught in this [article](https://medium.com/@felipeemidio).

A text note app to store your thoughts in remote places with no connection.

## Branches

The `master` branch refers to the "Local database" approach

The `cache-request` branch refers to the "Cache queries" and "Request queue" approaches.

## Backend

To make a functional PoC, a API in Go language was created. Checkout the code in this [link](https://github.com/felipeemidio/offline-first-api)

If you intend to recreate this project, remember to replace the `BASE_URL` in the `api_datasource.dart` file

## Running

Make use of the API backend project

```
flutter pub get
```

```
flutter run
```


