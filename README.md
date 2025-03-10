# Docker-compose for any-sync

Self-host for any-sync, designed for personal usage or for review and testing purposes.

> [!IMPORTANT]
> This image is suitable for running your personal self-hosted any-sync network for home usage.
> If you plan to self-host a heavily used any-sync network, please consider other options.

> [!WARNING]
> Before upgrading please read [Upgrade-Guide](../../wiki/Upgrade-Guide)

## Documentation

All of the documentation for this repository is located in the [Wiki](../../wiki).  
Please visit the Wiki for comprehensive guides, installation instructions and more.

## Getting Started

To get started, follow these steps:

1. **Install the necessary dependencies:**  
    You need to install Docker and Docker Compose <https://docs.docker.com/compose/install/>
2. **Clone the repository:**

    ```bash
    git clone https://github.com/anyproto/any-sync-dockercompose.git
    ```

3. **Navigate to the project directory:**

    ```bash
    cd any-sync-dockercompose
    ```

4. **Configuration:**  
    For configuration, use the `.env.override` file.  
    For example, setting an external IP for listening:

    ```bash
    echo 'EXTERNAL_LISTEN_HOSTS=<yourExternalIp1> <yourExternalIp2' >> .env.override
    ```

    More information can be found [here](../../wiki/Configuration).
5. **Run the project:**

    ```bash
    make start
    ```

For detailed instructions, please refer to the [Usage Guide](../../wiki/Usage) in the Wiki.

## Coolify One-Click Installation

Any-Sync can be easily deployed using [Coolify](https://coolify.io/), a self-hostable Heroku/Netlify alternative.

### Prerequisites

- A server with Coolify installed
- Access to the Coolify dashboard

### Installation Steps

1. In your Coolify dashboard, navigate to a coolify project (or create a new one), then click "New Resource" > "Public Git Repository".
2. Enter the repository URL: `https://github.com/ZanzyTHEbar/any-sync-dockercompose/tree/coolify`
3. Set the buildpack "Docker Compose" and click "Next"
4. Configure the environment variables as needed
5. For AWS integration, set up the following secrets in the Coolify dashboard:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
6. Click "Save" and then "Deploy"

Your Any-Sync instance will be automatically set up and ready to use!

## Contribution

Thank you for your desire to develop Anytype together!

❤️ This project and everyone involved in it is governed by the [Code of Conduct](https://github.com/anyproto/.github/blob/main/docs/CODE_OF_CONDUCT.md).

🧑‍💻 Check out our [contributing guide](https://github.com/anyproto/.github/blob/main/docs/CONTRIBUTING.md) to learn about asking questions, creating issues, or submitting pull requests.

🫢 For security findings, please email [security@anytype.io](mailto:security@anytype.io) and refer to our [security guide](https://github.com/anyproto/.github/blob/main/docs/SECURITY.md) for more information.

🤝 Follow us on [Github](https://github.com/anyproto) and join the [Contributors Community](https://github.com/orgs/anyproto/discussions).

---
Made by Any — a Swiss association 🇨🇭

Licensed under [MIT](./LICENSE.md).
