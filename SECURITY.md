# Security Policy

## Supported Versions

| Version       | Supported Until | Alternate Tag    | Info                          |
| ------------- | --------------- | ---------------- | ----------------------------- |
| <= 3.26       | Unsupported     |                  |                               |
| 3.28          | 23/06/2026      |                  |                               |
| 3.28-gdal3.6  | Unsupported     |                  | Version based on Ubuntu 22.04 |
| 3.28-gdal3.7  | 23/06/2026      |                  | Version based on Ubuntu 22.04 |
| 3.28-gdal3.8  | Best effort     | 3.28             | Version based on Ubuntu 22.04 |
| 3.30          | Unsupported     |                  |                               |
| 3.32          | Unsupported     |                  |                               |
| 3.34          | Best effort     |                  |                               |
| 3.34-gdal3.7  | Unsupported     |                  | Version based on Ubuntu 22.04 |
| 3.34-gdal3.8  | Best effort     | 3.34             | Version based on Ubuntu 22.04 |
| 3.36          | Unsupported     |                  |                               |
| 3.36-gdal3.8  | Unsupported     | 3.36             | Version based on Ubuntu 22.04 |
| 3.38          | Unsupported     |                  |                               |
| 3.38-gdal3.8  | Unsupported     | 3.38             | Version based on Ubuntu 22.04 |
| 3.40          | Best effort     |                  |                               |
| 3.40-gdal3.10 | Best effort     | 3.40, ltr        | Version based on Ubuntu 24.04 |
| 3.42          | Best effort     |                  |                               |
| 3.42-gdal3.10 | Best effort     | 3.32, lr, latest | Version based on Ubuntu 24.04 |

The initial support is aligned to the [upstream support](https://www.qgis.org/en/site/getinvolved/development/roadmap.html#release-schedule).

Exception: The version 3.22 will be supported until 23/06/2025 instead of 03/03/2023.

From the version 3.34, and for the version 3.28 we start to publish the image with the long tag (like `3.28-gdal3.6`) and the short tag (like `3.28`).
