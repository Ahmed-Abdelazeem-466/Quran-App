import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '..');
const sourceRoot = path.join(root, 'source', 'tafsir-saadi', 'raw');
const quranPath = path.join(root, 'assets', 'data', 'quran.json');
const partitionPath = path.join(root, 'source', 'quran-data.xml');
const outputPath = path.join(root, 'assets', 'data', 'tafsir_saadi.json');

const quran = JSON.parse(fs.readFileSync(quranPath, 'utf8'));
const verses = quran.surahs.flatMap((surah) =>
  surah.verses.map((verse) => ({...verse, surahNumber: surah.number})),
);
const verseByKey = new Map(verses.map((verse) => [verse.key, verse]));

const entries = [];
for (let surah = 1; surah <= 114; surah += 1) {
  const rawPath = path.join(sourceRoot, `${surah}.json`);
  if (!fs.existsSync(rawPath)) throw new Error(`Missing Tafsir source for surah ${surah}`);
  const records = JSON.parse(fs.readFileSync(rawPath, 'utf8'));
  for (const record of records) {
    const key = `${record.surah}:${record.ayah}`;
    const verse = verseByKey.get(key);
    if (!verse) throw new Error(`Tafsir record has an unknown Quran reference: ${key}`);
    if (typeof record.text !== 'string' || record.text.trim().isEmpty) {
      throw new Error(`Tafsir record has empty text: ${key}`);
    }
    entries.push({
      key,
      surah: record.surah,
      ayah: record.ayah,
      juz: verse.juz,
      text: record.text.trim(),
    });
  }
}
entries.sort((a, b) => verseByKey.get(a.key).globalNumber - verseByKey.get(b.key).globalNumber);

const seenKeys = new Set();
for (const entry of entries) {
  if (!seenKeys.add(entry.key)) throw new Error(`Duplicate Tafsir record: ${entry.key}`);
}

for (let index = 0; index < entries.length; index += 1) {
  const entry = entries[index];
  const next = entries[index + 1];
  const surah = quran.surahs[entry.surah - 1];
  entry.endAyah = next?.surah === entry.surah ? next.ayah - 1 : surah.verseCount;
  if (entry.endAyah < entry.ayah) throw new Error(`Invalid Tafsir range: ${entry.key}`);
  const startVerse = verseByKey.get(entry.key);
  const endVerse = verseByKey.get(`${entry.surah}:${entry.endAyah}`);
  entry.startGlobal = startVerse.globalNumber;
  entry.endGlobal = endVerse.globalNumber;
  entry.endJuz = endVerse.juz;
}

for (const surah of quran.surahs) {
  const ranges = entries.filter((entry) => entry.surah === surah.number);
  let expectedAyah = 1;
  for (const entry of ranges) {
    if (entry.ayah !== expectedAyah) {
      throw new Error(`Tafsir range gap in surah ${surah.number}: expected ayah ${expectedAyah}, found ${entry.ayah}`);
    }
    expectedAyah = entry.endAyah + 1;
  }
  if (expectedAyah !== surah.verseCount + 1) {
    throw new Error(`Tafsir range does not cover end of surah ${surah.number}`);
  }
}

const partitionXml = fs.readFileSync(partitionPath, 'utf8');
const quarterMatches = [...partitionXml.matchAll(/<quarter index="(\d+)" sura="(\d+)" aya="(\d+)"\s*\/>/g)];
if (quarterMatches.length !== 240) {
  throw new Error(`Expected 240 Rub boundaries, found ${quarterMatches.length}`);
}
const rubs = quarterMatches.map((match, index) => {
  const number = Number(match[1]);
  const startKey = `${match[2]}:${match[3]}`;
  const startVerse = verseByKey.get(startKey);
  const nextMatch = quarterMatches[index + 1];
  const endVerse = nextMatch
    ? verses.find((verse) => verse.globalNumber === verseByKey.get(`${nextMatch[2]}:${nextMatch[3]}`).globalNumber - 1)
    : verses.at(-1);
  if (!startVerse || !endVerse) throw new Error(`Invalid Rub boundary for Rub ${number}`);
  return {
    number,
    startKey,
    endKey: endVerse.key,
    startSurah: startVerse.surahNumber,
    startAyah: startVerse.number,
    endSurah: endVerse.surahNumber,
    endAyah: endVerse.number,
    juz: startVerse.juz,
    startGlobal: startVerse.globalNumber,
    endGlobal: endVerse.globalNumber,
  };
});

const output = {
  metadata: {
    title: 'تيسير الكريم الرحمن في تفسير كلام المنان',
    author: 'عبد الرحمن بن ناصر السعدي',
    language: 'ar',
    sourceName: 'Tafseer Al Saadi - Arabic',
    sourceUrl: 'https://qul.tarteel.ai/resources/tafsir/24',
    sourceNote: 'Arabic tafsir content is indexed offline by Quran verse. The user-provided PDF was inspected as the requested printed reference.',
    entryCount: entries.length,
    rubCount: rubs.length,
  },
  entries,
  rubs,
};

fs.writeFileSync(outputPath, `${JSON.stringify(output)}\n`);
console.log(`Wrote ${entries.length} Tafsir Al-Sa‘di entries and ${rubs.length} Rub indexes to ${outputPath}`);
