# SubwayBoard

A simple application showing the status of the NYC Subway system.
Essentially just a wrapper around the MTA's xml endpoint.

### Development

To start the application, run the following commands:

```bash
docker build -t subwayboard .
docker run -p 3000:3000 -e PORT=3000 subwayboard
```

### Deployment

```bash
docker build -t subwayboard .
heroku container:push web
```
