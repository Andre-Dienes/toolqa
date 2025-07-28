
# Assistente Virtual Inteligente BPlus

## Installation

1. **Clone the Repository**  
   Download the project repository to your local machine using Git:

   ```bash
   $ git clone https://github.com/bplus-tecnologia/assistente_virtual_inteligente
   ```

2. **Configure Environment Variables**  
   - Create a `.env` file in the project’s root directory, containing your Azure keys.
   - Additionally, create a `.env` file inside the `python/assistente` folder for the frontend configuration.

## Build and Run the Containers

1. **Build the Docker Containers**  
   Run the following command to build the Docker containers without using any cached layers:

   ```bash
   $ docker-compose build --no-cache --progress=plain
   ```

2. **Start the Containers**  
   After building, start the containers in detached mode:

   ```bash
   $ docker-compose up -d
   ```

## Data Ingestion

1. **Access the IRIS Terminal**  
   Open the IRIS terminal by executing the following command:

   ```bash
   $ docker-compose exec iris iris session iris -U TOOL
   ```

2. **Initialize the AI Model**  
   Upon first use, you will need to run the initialization script to train the AI:

   ```text
   TOOL>Do ##class(bplus.Ingest).Init()
   ```

3. **Exit the Terminal**  
   To exit the terminal, type `HALT` or simply `H` (case insensitive).

## Start the Interoperability Production

To start the interoperability production required for API usage, [click here](http://localhost:52773/csp/TOOL/EnsPortal.ProductionConfig.zen?PRODUCTION=bplus.tool.producao).


## How to Stop and Clean Up Containers

1. **Stop the Containers**  
   To stop the running containers and their associated volumes, use:

   ```bash
   $ docker-compose down -v
   ```
   
   To remove all images, use:

   ```bash
   $ docker rmi $(docker images -aq)
   ```

   Also, you can use Docker's volume prune command to remove all unused volumes:

   ```bash
   $ docker volume prune -f
   ```


2. **Delete Containers and Networks**  
   If you wish to remove all stopped containers and their associated networks, you can use Docker's system prune command:

   ```bash
   $ docker system prune -f
   ```

   This command will free up space by removing any unused containers, networks, volumes, and images that are not referenced by any active containers. Be cautious when using this as it permanently deletes these resources.
