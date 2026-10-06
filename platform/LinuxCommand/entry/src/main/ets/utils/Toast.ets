/**
 * 基于 UIContext 的 Toast 封装（官方推荐替代已弃用的 promptAction.showToast 全局函数）。
 * showToast 可能抛出参数错误等异常，这里捕获后静默忽略，保证主流程不受影响。
 */
export function showToast(uiContext: UIContext, message: string): void {
  try {
    uiContext.getPromptAction().showToast({ message: message });
  } catch (error) {
    // Toast 失败不影响主流程
  }
}
