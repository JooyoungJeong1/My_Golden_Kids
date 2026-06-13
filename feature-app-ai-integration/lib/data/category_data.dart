import '../models/category.dart';

// ───────────────────────────────────────────
// 카테고리 데이터
// ───────────────────────────────────────────

const Map<String, CategoryDetail> categoryDetails = {
  '종이류': CategoryDetail(
    subtitle: '박스·신문지·책·노트',
    steps: [
      CategoryStep(title: '이물질 제거', description: '테이프·철핀·비닐코팅 부분을 제거해요.'),
      CategoryStep(title: '펼치기', description: '물기에 젖지 않게 반듯하게 펴서 모아줘요.'),
      CategoryStep(title: '묶어 배출', description: '차곡차곡 쌓은 뒤 끈으로 묶어 종이류로 배출해요.'),
    ],
    warning: '영수증·택배전표·코팅지·종이호일은 일반쓰레기로 버려주세요.',
  ),

  '캔류': CategoryDetail(
    subtitle: '음료캔·통조림캔·부탄가스',
    steps: [
      CategoryStep(title: '비우기', description: '내용물을 완전히 비우고 물로 헹궈줘요.'),
      CategoryStep(title: '분리하기', description: '플라스틱 뚜껑 등 다른 재질은 제거해줘요.'),
      CategoryStep(title: '배출', description: '캔 전용 수거함 또는 금속류로 배출해요.'),
    ],
    warning: '부탄가스는 통풍이 잘되는 곳에서 노즐을 눌러 가스를 빼고 배출해주세요.',
  ),

  '유리': CategoryDetail(
    subtitle: '음료수병·술병·소스병',
    steps: [
      CategoryStep(title: '비우기', description: '내용물을 비우고 물로 헹궈 이물질을 제거해요.'),
      CategoryStep(title: '분리하기', description: '뚜껑 등 다른 재질은 제거한 뒤 따로 배출해요.'),
      CategoryStep(title: '배출', description: '깨지지 않도록 주의해 유리병 수거함에 배출해요.'),
    ],
    warning: '깨진 유리·도자기·내열유리는 유리병 수거함에 넣지 말아주세요.',
  ),

  '플라스틱': CategoryDetail(
    subtitle: 'PET·PE·PP·PS 용기',
    steps: [
      CategoryStep(title: '비우기', description: '내용물을 비우고 물로 헹궈 이물질을 제거해요.'),
      CategoryStep(title: '분리하기', description: '라벨·부속품 등 다른 재질은 제거해줘요.'),
      CategoryStep(title: '압착하기', description: '투명 PET병은 압착 후 뚜껑을 닫아 배출해요.'),
      CategoryStep(title: '배출', description: '플라스틱 수거함에 배출해요.'),
    ],
    warning: '오염이 심하거나 다른 재질이 붙어 있으면 일반쓰레기로 배출해주세요.',
  ),

  '비닐': CategoryDetail(
    subtitle: '비닐봉투·랩·필름',
    steps: [
      CategoryStep(title: '비우기', description: '내용물을 비우고 이물질을 제거해요.'),
      CategoryStep(title: '모으기', description: '흩날리지 않도록 투명 또는 반투명 봉투에 담아줘요.'),
      CategoryStep(title: '배출', description: '비닐류 수거함 또는 지정된 방식으로 배출해요.'),
    ],
    warning: '음식물이 묻어 깨끗이 제거되지 않는 비닐은 일반쓰레기로 버려주세요.',
  ),

  '기타·처치곤란': CategoryDetail(
    subtitle: '복합재질·전지·전자제품',
    steps: [
      CategoryStep(title: '재질 확인', description: '분리배출 표시와 재질을 먼저 확인해요.'),
      CategoryStep(title: '분리하기', description: '분리 가능한 부분은 재질별로 나눠 배출해요.'),
      CategoryStep(title: '별도 배출', description: '전지·전자제품·형광등은 전용수거함에 배출해요.'),
    ],
    warning: '분리 불가능한 복합재질은 지자체 기준에 따라 배출해주세요.',
  ),
};
