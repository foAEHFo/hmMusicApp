export function formatNumber(number: number): string {
  if (number >= 10000) {
    // 转换为万单位，保留1位小数
    const fansInTenThousand = number / 10000;
    // 避免显示多余的0（如1.0万 -> 1万）
    return fansInTenThousand.toFixed(1).replace(/\.0$/, '') + '万';
  }
  return number.toString(); // 不足1万直接显示
}