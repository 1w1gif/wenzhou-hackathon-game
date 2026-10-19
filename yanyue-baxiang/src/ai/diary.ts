/**
 * AI 日记模块:每条世界线落定时,以衍月口吻写一篇日记。
 * 设计为可插拔:
 *  - 若 window.ZCODE_AI_KEY 存在(比赛演示时注入),调用 OpenAI 兼容接口;
 *  - 否则静默降级为本地文案,游戏主线完全不受影响。
 * 调用是"发射后不管":场景先继续,日记写好后引月札里可见。
 */

export interface DiaryResult {
  text: string;
  source: 'ai' | 'local';
}

const LOCAL_FALLBACKS: Record<string, string[]> = {
  '朔': ['无光的夜,灯是我点亮的。若每条线都有一个人守夜,那今夜守夜的人是我。'],
  '峨眉': ['此界的戏才开场,井水替我记住了那个名字。名字先于人存在——那我该先找到名字,还是先找到人?'],
  '弦': ['我踏着影子过了桥。原来断掉的东西没有消失,只是留在了另一条线上。人是不是也一样?'],
  '盈凸': ['哑钟无声,八处同鸣。世界与世界的缝,比我想象的窄。'],
  '望': ['祭文的空行里藏着他的名字。被唤走的人不在一条线上——那我要找的,从来就不是一条路。'],
  '亏凸': ['船票的回程未用。这意味着,在某个地方,他还回得来。我把票根贴在心口。'],
  '下弦': ['他画了一生的背影,都是提灯的我。半面镜子贴着掌心,像贴着半句没说完的话。'],
  '残': ['雁声比人声多的季节,风筝替他递了信。他说,选我还敢回头的那个世界。'],
};

const PROMPT_TEMPLATE = (phase: string, role: string, clueNames: string[], choice: string) => `你是游戏《衍月·八相》的女主角衍月,一位能穿越平行时空、唯一保留全部记忆的女子。文风:古典白话,克制,意象化,不超过 60 字,只输出日记正文。

今夜你身处「${phase}」月相的世界线,谢郎在此界是「${role}」。你手中有这些跨时空线索:${clueNames.join('、') || '尚无'}。你刚做出选择:${choice}。

写一篇今夜的日记。`;

function randomLocal(phase: string): string {
  const arr = LOCAL_FALLBACKS[phase] ?? ['今夜月色如旧,而我仍在新的一条线上行走。'];
  return arr[Math.floor(Math.random() * arr.length)];
}

async function callAI(prompt: string, signal: AbortSignal): Promise<string | null> {
  const w = window as unknown as { ZCODE_AI_KEY?: string; ZCODE_AI_BASE?: string; ZCODE_AI_MODEL?: string };
  const key = w.ZCODE_AI_KEY;
  if (!key) return null;
  const base = w.ZCODE_AI_BASE ?? 'https://api.openai.com/v1';
  const model = w.ZCODE_AI_MODEL ?? 'gpt-4o-mini';
  const resp = await fetch(`${base}/chat/completions`, {
    method: 'POST',
    signal,
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${key}` },
    body: JSON.stringify({
      model,
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 120,
      temperature: 0.9,
    }),
  });
  if (!resp.ok) return null;
  const data = (await resp.json()) as { choices?: Array<{ message?: { content?: string } }> };
  const text = data.choices?.[0]?.message?.content?.trim();
  return text || null;
}

/**
 * 请求日记。返回立即生效的本地文案用于占位,
 * AI 结果在后台返回后由回调替换(状态层直接改 node.diary)。
 */
export async function requestDiary(
  phase: string,
  role: string,
  clueNames: string[],
  choice: string,
  onDone: (r: DiaryResult) => void,
): Promise<void> {
  const local = randomLocal(phase);
  const w = window as unknown as { ZCODE_AI_KEY?: string };
  if (!w.ZCODE_AI_KEY) {
    onDone({ text: local, source: 'local' });
    return;
  }
  onDone({ text: local, source: 'local' });
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), 12000);
  try {
    const ai = await callAI(PROMPT_TEMPLATE(phase, role, clueNames, choice), ctrl.signal);
    if (ai) onDone({ text: ai, source: 'ai' });
  } catch {
    /* 保持本地文案 */
  } finally {
    clearTimeout(timer);
  }
}
