# OpenAI API Setup Guide

This guide will help you configure OpenAI API integration for AI-powered business recommendations.

## Setup Steps

### 1. Get OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in to your account
3. Navigate to [API Keys](https://platform.openai.com/api-keys)
4. Click "Create new secret key"
5. Copy the API key (you won't be able to see it again!)

### 2. Configure API Key

#### Option A: Environment Variable (Recommended for Development)

```bash
export OPENAI_API_KEY="sk-your-api-key-here"
```

Or add to your `.env` file (if using dotenv gem):
```
OPENAI_API_KEY=sk-your-api-key-here
```

#### Option B: Rails Encrypted Credentials (Recommended for Production)

```bash
EDITOR="code --wait" bin/rails credentials:edit
```

Add the following:
```yaml
openai:
  api_key: sk-your-api-key-here
```

### 3. Usage

Once configured, you can use the "Analyze with AI" button on any completed upload to generate industry-specific business recommendations.

## Cost Information

- **Model Used**: GPT-4o-mini (cost-effective)
- **Pricing**: ~$0.15 per 1M input tokens, ~$0.60 per 1M output tokens
- **Typical Cost**: $0.01 - $0.10 per analysis (depending on data size)

Example:
- 100 uploads/month × $0.05/analysis = $5/month
- Much more cost-effective than dedicated AI services!

## Features

- ✅ Industry-specific prompts (same as Power BI)
- ✅ Actionable business recommendations
- ✅ Key insights and opportunities
- ✅ Risk analysis
- ✅ Next steps suggestions

## Troubleshooting

**Error: "OpenAI API key not configured"**
- Make sure you've set the API key using one of the methods above
- Restart your Rails server after setting environment variables

**Error: "AI analysis failed"**
- Check your API key is valid
- Verify you have credits in your OpenAI account
- Check Rails logs for detailed error messages

## Security Notes

- Never commit API keys to version control
- Use environment variables or encrypted credentials
- Rotate API keys regularly
- Monitor usage in OpenAI dashboard

