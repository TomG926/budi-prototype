# Budi Prototype - AI-Powered Business Intelligence Platform

Budi is a Rails 8 application that transforms business data into actionable insights through AI-powered analysis. Users can upload CSV files from any industry (salon, retail, restaurant, healthcare, etc.), which are automatically stored in PostgreSQL with dynamic schema detection. The platform supports seamless integration with Power BI's REST API for advanced data visualization and analysis, enabling businesses to push their data directly into Power BI datasets for comprehensive reporting.

The platform leverages OpenAI's GPT-4o-mini model to generate industry-specific business recommendations, analyzing uploaded data with tailored prompts and metrics for each business sector. Users can interact with their data through an intelligent Q&A feature, asking questions in natural language and receiving data-driven answers that are automatically saved for future reference. The system automatically generates visual charts and graphs based on the data structure, highlighting key metrics like revenue by service, staff performance, and other business-critical insights.

With user authentication powered by Devise, each user's data is securely scoped and isolated. The application provides a dedicated Analyses section where users can view all their AI-generated insights, save and revisit previous questions and answers, and trigger new analyses on their datasets. The modern, Revolut-inspired interface ensures a smooth user experience while delivering powerful business intelligence capabilities that work across diverse industries and data structures.

## Features

- **Flexible CSV Upload**: Accept any CSV structure with automatic schema detection
- **Dynamic Schema Handling**: Automatically detects column types (DateTime, Number, String, Boolean)
- **Power BI Integration**: Automatically creates push datasets and syncs data via REST API
- **Background Processing**: CSV imports run asynchronously for better UX
- **PostgreSQL Storage**: All data stored in PostgreSQL with JSONB for flexibility
- **Power BI AI Features**: Use Power BI's built-in AI visuals:
  - **Key Influencers** - Find what drives your metrics
  - **Anomaly Detection** - Detect outliers in time series
  - **Smart Narrative** - Get natural language insights
  - **Decomposition Tree** - Drill down into contributing factors

## Tech Stack

- **Rails 8.1.1**
- **PostgreSQL** (with JSONB for flexible data storage)
- **Power BI REST API**
- **Azure AD OAuth2** (for Power BI authentication)
- **Tailwind CSS** (for UI)
- **Solid Queue** (for background jobs)

## Setup

### 1. Database Setup

```bash
bin/rails db:create db:migrate
```

### 2. Configure Power BI (Optional)

See [POWER_BI_SETUP.md](POWER_BI_SETUP.md) for detailed instructions on:
- Creating Azure AD App Registration
- Setting up API permissions
- Configuring credentials

Quick setup:
```bash
# Edit Rails credentials
EDITOR="code --wait" bin/rails credentials:edit

# Add:
# power_bi:
#   tenant_id: "your-tenant-id"
#   client_id: "your-client-id"
#   client_secret: "your-client-secret"
#   workspace_id: "your-workspace-id"  # Optional
```

Or use environment variables:
```bash
export POWER_BI_TENANT_ID="your-tenant-id"
export POWER_BI_CLIENT_ID="your-client-id"
export POWER_BI_CLIENT_SECRET="your-client-secret"
export POWER_BI_WORKSPACE_ID="your-workspace-id"  # Optional
```

### 3. Start the Server

```bash
bin/rails server
```

Visit `http://localhost:3000`

## Usage

1. **Upload CSV**: Click "New Upload" and select your CSV file
2. **Auto-Processing**: The system will:
   - Detect CSV schema automatically
   - Store data in PostgreSQL
   - Create Power BI dataset (if configured)
   - Push data to Power BI in batches
3. **View Results**: Check the upload status page for Power BI dataset ID
4. **Analyze in Power BI**: 
   - Open Power BI Desktop or Service
   - Connect to your dataset
   - Use AI visuals to generate insights

## Data Model

### Upload
- Stores metadata about each CSV upload
- Tracks processing status
- Stores Power BI dataset information

### DataRow
- Flexible JSONB storage for any CSV structure
- Each row stored as `{ "column_name": "value" }`
- Linked to Upload via foreign key

## Architecture

```
CSV Upload → Background Job → Schema Detection → PostgreSQL (JSONB)
                                            ↓
                                      Power BI REST API
                                            ↓
                                      Power BI Dataset
                                            ↓
                                      AI Analysis (Key Influencers, Anomaly Detection, etc.)
```

## API Endpoints

- `GET /` - List all uploads
- `GET /uploads/new` - Upload form
- `POST /uploads` - Create new upload (triggers background job)
- `GET /uploads/:id` - View upload details and sample data

## Background Jobs

CSV processing runs via `CsvImportJob`:
- Parses CSV
- Detects schema
- Stores in PostgreSQL
- Pushes to Power BI (if configured)

## Power BI Integration

The system uses Power BI Push Datasets:
- **Dataset Creation**: Automatically created with detected schema
- **Batch Pushes**: Data pushed in batches of 1000 rows
- **Dynamic Schema**: Schema matches CSV columns exactly
- **Error Handling**: Failed Power BI pushes don't fail the import

## Multi-Client Support

Each upload can have different CSV structures:
- Different column names
- Different data types
- Different schemas
- All stored flexibly in JSONB

Each upload gets its own Power BI dataset with the appropriate schema.

## Troubleshooting

### CSV import fails
- Check Rails logs: `tail -f log/development.log`
- Ensure CSV has headers in first row
- Verify file is valid CSV format

### Power BI push fails
- Verify credentials are correct
- Check Azure AD app permissions
- Ensure `Dataset.ReadWrite.All` permission granted
- Check Power BI service status

### Data not appearing in Power BI
- Verify dataset ID is correct
- Check Power BI service logs
- Ensure workspace ID is correct (if specified)

## Development

```bash
# Run migrations
bin/rails db:migrate

# Run background job processor (in separate terminal)
bin/rails solid_queue:start

# Run tests
bin/rails test

# Check logs
tail -f log/development.log
```

## Production Considerations

1. **Credentials**: Use encrypted credentials or environment variables
2. **Background Jobs**: Use proper job queue (Redis, Sidekiq, etc.)
3. **Error Monitoring**: Add Sentry or similar
4. **Rate Limiting**: Power BI API has rate limits
5. **Data Retention**: Consider cleanup jobs for old uploads
6. **Security**: Implement authentication/authorization
7. **File Size Limits**: Add validation for CSV file sizes

## License

MIT
