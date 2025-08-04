interface LyricItem {
  time: number;          // 毫秒时间戳
  text: string;          // 原版歌词文本
  translateText: string; // 翻译歌词文本
}

function parseLyrics(lyrics: string): Map<number, string> {
  const result = new Map<number, string>();
  const lines = lyrics.split("\n");

  for (const line of lines) {
    const trimmedLine = line.trim();
    if (!trimmedLine) continue; // 跳过完全空行

    // 匹配时间标签 [mm:ss.SSS]
    const match = trimmedLine.match(/^\[(\d+):(\d+)\.(\d+)\](.*)$/);
    if (match) {
      const min = parseInt(match[1], 10);
      const sec = parseInt(match[2], 10);
      const ms = parseInt(match[3], 10);
      const text = match[4].trim();

      // 关键修改：跳过空文本行 [1,5](@ref)
      if (!text) continue; // 忽略有时间标签但歌词为空的条目

      // 计算总秒数
      const time = min * 60 + sec + ms/1000;
      result.set(time, text);
    }
  }
  return result;
}

export function mergeLyrics(original: string, translation: string): LyricItem[] {
  const originalMap = parseLyrics(original);
  const translationMap = parseLyrics(translation);

  // 获取并排序原版时间戳
  const sortedTimes = Array.from(originalMap.keys()).sort((a, b) => a - b);

  return sortedTimes.map(time => ({
    time,
    text: originalMap.get(time) ?? "",           // 原版歌词
    translateText: translationMap.get(time) ?? "" // 翻译歌词（无则留空）
  } as LyricItem));
}