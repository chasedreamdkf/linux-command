import { marked } from 'marked';

// 配置marked - 适配不同版本的marked
try {
  if (typeof marked.use === 'function') {
    // 新版本marked使用use方法
    marked.use({
      breaks: true,
      gfm: true,
    });
  } else if (typeof marked.setOptions === 'function') {
    // 旧版本marked使用setOptions方法
    marked.setOptions({
      breaks: true,
      gfm: true,
    });
  }
} catch (error) {
  // 忽略配置错误，确保测试能继续运行
  console.warn('Failed to configure marked:', error);
}

export interface CommandInfo {
  name: string;
  description: string;
  html: string;
}

export async function parseMarkdown(content: string): Promise<CommandInfo> {
  // 提取命令名称（第一个标题）
  const nameMatch = content.match(/^#\s+([^\n]+)/);
  const name = nameMatch ? nameMatch[1].trim() : '';

  // 提取描述（第一个段落）
  const descriptionMatch = content.match(/^#[^\n]+\n+([^\n]+)/);
  const description = descriptionMatch ? descriptionMatch[1].trim() : '';

  // 使用marked解析Markdown为HTML
  let html = '';
  try {
    // 尝试不同的marked调用方式以适应不同版本
    if (typeof marked.parse === 'function') {
      html = await marked.parse(content);
    } else if (typeof marked === 'function') {
      html = await marked(content);
    } else {
      // 在测试环境中，如果marked未正确模拟，返回mock的HTML
      // if (process.env.NODE_ENV === 'test') {
      //   html = `<h1>${name}</h1>${description ? `<p>${description}</p>` : ''}`
      // } else {
      //   html = content
      // }
    }
  } catch (error) {
    console.warn('Failed to parse markdown:', error);
    html = content;
  }

  return {
    name,
    description,
    html,
  };
}
