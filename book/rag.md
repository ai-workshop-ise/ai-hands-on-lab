# Retrieval Augmented Generation (RAG)

```{seealso}
New to copilot and RAG concepts? 
- Watch [Vector search and state of the art retrieval for Generative AI apps.](https://ignite.microsoft.com/en-US/sessions/18618ca9-0e4d-4f9d-9a28-0bc3ef5cf54e?source=sessions)
- Read [Retrieval Augmented Generation (RAG) in Azure AI Search](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview)
```
RAG is not the only solution for incorporating domain knowledge:
![domain-knowledge](domain-knowledge.png)


How does RAG work?

![RAG_pattern](rag-pattern.png)

## Approaches for RAG with Azure AI Search
Microsoft has several built-in implementations for using Azure AI Search in a RAG solution.

1. Azure AI Studio, [use a vector index and retrieval augmentation - Preview](https://learn.microsoft.com/en-us/azure/ai-studio/concepts/retrieval-augmented-generation).
2. Azure OpenAI Studio, [use a search index with or without vectors - Preview](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/use-your-data?tabs=ai-search).
3. Azure Machine Learning, [use a search index as a vector store in a prompt flow - Preview](https://learn.microsoft.com/en-us/azure/machine-learning/how-to-create-vector-index?view=azureml-api-2).

### 1. Azure AI Studio
1. Go to `ai.azure.com`
2. 
