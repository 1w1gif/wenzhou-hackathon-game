export function Sprite({ svg, className }: { svg: string; className?: string }) {
  return (
    <div className={className ? `sprite ${className}` : "sprite"}
      dangerouslySetInnerHTML={{ __html: svg }} />
  );
}
