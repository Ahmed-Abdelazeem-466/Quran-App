import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '..');
const textPath = path.join(root, 'source/tanzil-mirror/data/quran-uthmani.txt');
const metadataPath = path.join(root, 'source/tanzil-mirror/data/quran-data.js');
const outputPath = path.join(root, 'assets/data/quran.json');

const quranText = fs.readFileSync(textPath, 'utf8');
const metadataText = fs.readFileSync(metadataPath, 'utf8');

function section(name) {
  const marker = `QuranData.${name} = [`;
  const start = metadataText.indexOf(marker);
  if (start < 0) throw new Error(`Missing metadata section: ${name}`);
  const end = metadataText.indexOf('\n];', start);
  if (end < 0) throw new Error(`Unterminated metadata section: ${name}`);
  return metadataText.slice(start + marker.length, end);
}

const windows1252Bytes = new Map([
  ['€', 0x80], ['‚', 0x82], ['ƒ', 0x83], ['„', 0x84], ['…', 0x85],
  ['†', 0x86], ['‡', 0x87], ['ˆ', 0x88], ['‰', 0x89], ['Š', 0x8a],
  ['‹', 0x8b], ['Œ', 0x8c], ['Ž', 0x8e], ['‘', 0x91], ['’', 0x92],
  ['“', 0x93], ['”', 0x94], ['•', 0x95], ['–', 0x96], ['—', 0x97],
  ['˜', 0x98], ['™', 0x99], ['š', 0x9a], ['›', 0x9b], ['œ', 0x9c],
  ['ž', 0x9e], ['Ÿ', 0x9f],
]);

function restoreUtf8(value) {
  const bytes = [...value].map((character) => {
    const special = windows1252Bytes.get(character);
    if (special !== undefined) return special;
    const codePoint = character.codePointAt(0);
    if (codePoint <= 0xff) return codePoint;
    throw new Error(`Unsupported metadata mojibake character: ${character}`);
  });
  return Buffer.from(bytes).toString('utf8');
}

function pairRows(name) {
  return [...section(name).matchAll(/\[(\d+),\s*(\d+)\]/g)].map((match) => ({
    surah: Number(match[1]),
    ayah: Number(match[2]),
  }));
}

const surahRows = [...section('Sura').matchAll(
  /\[(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*'([^']*)',\s*"([^"]*)",\s*'([^']*)',\s*'([^']*)'\]/g,
)].map((match, index) => ({
  number: index + 1,
  start: Number(match[1]),
  verseCount: Number(match[2]),
  revelationOrder: Number(match[3]),
  rukuCount: Number(match[4]),
  name: restoreUtf8(match[5]),
  transliteration: match[6],
  englishName: match[7],
  revelationType: match[8] === 'Meccan' ? 'مكية' : 'مدنية',
}));

const juzBoundaries = pairRows('Juz').filter((item) => item.surah <= 114);
const pageBoundaries = pairRows('Page').filter((item) => item.surah <= 114);
const sajdahRows = [...section('Sajda').matchAll(
  /\[(\d+),\s*(\d+),\s*'([^']+)'\]/g,
)].map((match) => ({
  surah: Number(match[1]),
  ayah: Number(match[2]),
  type: match[3],
}));
const sajdahByKey = new Map(
  sajdahRows.map((item) => [`${item.surah}:${item.ayah}`, item.type]),
);

if (surahRows.length !== 114) {
  throw new Error(`Expected 114 surahs, found ${surahRows.length}`);
}
if (juzBoundaries.length !== 30) {
  throw new Error(`Expected 30 juz boundaries, found ${juzBoundaries.length}`);
}
if (pageBoundaries.length !== 604) {
  throw new Error(`Expected 604 page boundaries, found ${pageBoundaries.length}`);
}

const verses = quranText
  .split(/\r?\n/)
  .map((line) => line.match(/^(\d+)\|(\d+)\|(.+)$/))
  .filter(Boolean)
  .map((match, index) => ({
    globalNumber: index + 1,
    surah: Number(match[1]),
    number: Number(match[2]),
    text: match[3],
  }));

if (verses.length !== 6236) {
  throw new Error(`Expected 6236 verses, found ${verses.length}`);
}

function isAtOrAfter(verse, boundary) {
  return verse.surah > boundary.surah ||
    (verse.surah === boundary.surah && verse.number >= boundary.ayah);
}

let juzIndex = 0;
let pageIndex = 0;
for (const verse of verses) {
  while (
    juzIndex + 1 < juzBoundaries.length &&
    isAtOrAfter(verse, juzBoundaries[juzIndex + 1])
  ) {
    juzIndex += 1;
  }
  while (
    pageIndex + 1 < pageBoundaries.length &&
    isAtOrAfter(verse, pageBoundaries[pageIndex + 1])
  ) {
    pageIndex += 1;
  }
  verse.key = `${verse.surah}:${verse.number}`;
  verse.juz = juzIndex + 1;
  verse.page = pageIndex + 1;
  const sajdahType = sajdahByKey.get(verse.key);
  verse.sajdah = sajdahType
    ? { type: sajdahType === 'obligatory' ? 'واجبة' : 'مستحبة' }
    : null;
}

const surahs = surahRows.map((metadata) => {
  const surahVerses = verses.filter((verse) => verse.surah === metadata.number);
  if (surahVerses.length !== metadata.verseCount) {
    throw new Error(
      `Surah ${metadata.number}: expected ${metadata.verseCount} verses, found ${surahVerses.length}`,
    );
  }
  return {
    ...metadata,
    firstJuz: surahVerses[0].juz,
    firstPage: surahVerses[0].page,
    verses: surahVerses.map(({ surah: _, ...verse }) => verse),
  };
});

const juzs = juzBoundaries.map((boundary, index) => {
  const next = juzBoundaries[index + 1];
  const juzVerses = verses.filter((verse) => {
    if (verse.juz !== index + 1) return false;
    return true;
  });
  return {
    number: index + 1,
    startKey: `${boundary.surah}:${boundary.ayah}`,
    startSurah: boundary.surah,
    startAyah: boundary.ayah,
    endKey: juzVerses.at(-1).key,
    endSurah: juzVerses.at(-1).surah,
    endAyah: juzVerses.at(-1).number,
    nextStartKey: next ? `${next.surah}:${next.ayah}` : null,
    verseCount: juzVerses.length,
  };
});

const output = {
  metadata: {
    title: 'القرآن الكريم',
    riwayah: 'حفص عن عاصم',
    surahCount: surahs.length,
    verseCount: verses.length,
    juzCount: juzs.length,
    pageCount: pageBoundaries.length,
    sourceEdition: 'مصحف المدينة النبوية',
    textSource: 'Tanzil Quran Text (Uthmani, Version 1.1)',
    textLicense: 'Creative Commons Attribution 3.0',
    sourceUrl: 'https://tanzil.net/',
  },
  juzs,
  surahs,
};

fs.mkdirSync(path.dirname(outputPath), { recursive: true });
fs.writeFileSync(outputPath, `${JSON.stringify(output)}\n`, 'utf8');

const outputVerseCount = output.surahs.reduce(
  (total, surah) => total + surah.verses.length,
  0,
);
console.log(
  JSON.stringify({
    output: outputPath,
    surahs: output.surahs.length,
    verses: outputVerseCount,
    juzs: output.juzs.length,
    pages: output.metadata.pageCount,
    sajdahs: sajdahRows.length,
  }),
);
