# Security Policy

## Supported Versions

| Version      | Supported Until | Alternate Tag | Info                                    |
| ------------ | --------------- | ------------- | --------------------------------------- |
| <= 3.14      | Unsupported     |               |                                         |
| 3.16         | Best effort     |               | Version based on GDAL 3.1, Ubuntu 20.04 |
| 3.18         | Unsupported     |               |                                         |
| 3.20         | Unsupported     |               |                                         |
| 3.22         | 23/06/2025      |               | Version based on GDAL 3.3, Ubuntu 20.04 |
| 3.24         | Unsupported     |               |                                         |
| 3.26         | Unsupported     |               |                                         |
| 3.28         | 23/02/2024      |               |                                         |
| 3.28-gdal3.6 | Best effort     |               | Version based on Ubuntu 22.04           |
| 3.28-gdal3.7 | Best effort     | 3.28, ltr     | Version based on Ubuntu 22.04           |
| 3.30         | 23/06/2023      |               | Version based on GDAL 3.6, Ubuntu 22.04 |
| 3.32         | 27/10/2023      | lr, latest    | Version based on GDAL 3.7, Ubuntu 22.04 |

The initial support is aligned to the [upstream support](https://www.qgis.org/en/site/getinvolved/development/roadmap.html#release-schedule).

Exception: The version 3.22 will be supported until 23/06/2025 instead of 03/03/2023.

From the version 3.34, and for the version 3.28 we start to publish the image with the long tag (like `3.28-gdal3.6`) and the short tag (like `3.28`).
