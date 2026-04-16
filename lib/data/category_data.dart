import '../models/category.dart';

// ───────────────────────────────────────────
// 카테고리 데이터
// ───────────────────────────────────────────

const Map<String, CategoryDetail> categoryDetails = {
  '종이류': CategoryDetail(
    subtitle: '박스·신문지·책·영수증',
    steps: [
      CategoryStep(title: '펼치기', description: '박스는 테이프·스티커를 제거하고 납작하게 펼쳐주세요.'),
      CategoryStep(
        title: '분리하기',
        description: '코팅된 부분, 스프링, 플라스틱 커버는 따로 분리합니다.',
      ),
      CategoryStep(
        title: '묶기',
        description: '끈으로 묶거나 박스 안에 넣어 종이류 수거함에 배출합니다.',
      ),
    ],
    warning: '영수증·코팅지·기름 묻은 종이는 일반쓰레기로 버리세요.',
  ),
  '캔류': CategoryDetail(
    subtitle: '음료캔·통조림·부탄가스',
    steps: [
      CategoryStep(title: '비우기', description: '내용물을 완전히 비우고 물로 한 번 헹궈주세요.'),
      CategoryStep(title: '찌그러트리기', description: '부피를 줄이기 위해 발로 밟아 찌그러트려주세요.'),
      CategoryStep(title: '배출', description: '캔 전용 수거함 또는 금속 수거함에 넣어주세요.'),
    ],
    warning: '부탄가스 캔은 반드시 구멍을 뚫어 가스를 완전히 빼고 배출하세요.',
  ),
  '유리': CategoryDetail(
    subtitle: '유리병·술병·소스병',
    steps: [
      CategoryStep(title: '비우기', description: '내용물을 비우고 물로 헹궈 이물질을 제거하세요.'),
      CategoryStep(
        title: '뚜껑 분리',
        description: '금속 뚜껑→캔류, 플라스틱 뚜껑→플라스틱으로 분리 배출합니다.',
      ),
      CategoryStep(
        title: '배출',
        description: '유리 전용 수거함에 넣어주세요. 깨진 유리는 별도 처리하세요.',
      ),
    ],
    warning: '깨진 유리는 신문지로 싸서 일반쓰레기 봉투에 넣어주세요. 유리 수거함에 넣으면 안 돼요.',
  ),
  '플라스틱': CategoryDetail(
    subtitle: 'PET·PP·PE·PS 용기',
    steps: [
      CategoryStep(title: '라벨 제거', description: '비닐 라벨은 완전히 제거해주세요.'),
      CategoryStep(title: '헹구기', description: '내용물을 비우고 물로 헹궈주세요.'),
      CategoryStep(
        title: '찌그러트리기',
        description: 'PET병은 찌그러트려 뚜껑을 닫아 부피를 줄여주세요.',
      ),
      CategoryStep(
        title: '배출',
        description: '플라스틱 수거함에 배출합니다. 오염이 심하면 일반쓰레기로.',
      ),
    ],
    warning: '스티로폼(발포 스티렌)은 별도 스티로폼 전용 수거함에 넣어야 합니다.',
  ),
  '비닐': CategoryDetail(
    subtitle: '봉투·랩·필름·지퍼백',
    steps: [
      CategoryStep(title: '내용물 제거', description: '음식물 등 이물질이 없도록 깨끗이 비워주세요.'),
      CategoryStep(title: '분리', description: '테이프·스티커 등 이물질을 제거해주세요.'),
      CategoryStep(title: '배출', description: '비닐 전용 수거함 또는 투명비닐봉투에 모아 배출합니다.'),
    ],
    warning: '오염된 비닐, 음식물 묻은 봉투는 일반쓰레기로 버리세요.',
  ),
  '기타·처치곤란': CategoryDetail(
    subtitle: '처치곤란·복합재질·특수품목',
    steps: [
      CategoryStep(
        title: '확인',
        description: '재질 표시를 먼저 확인하세요. 두 가지 이상이면 복합재질입니다.',
      ),
      CategoryStep(
        title: '분리 가능 여부',
        description: '분리 가능한 부품은 각 재질별로 분리 배출합니다.',
      ),
      CategoryStep(
        title: '불가 시',
        description: '분리 불가능한 복합재질은 일반쓰레기봉투에 넣어 배출합니다.',
      ),
    ],
    warning: '형광등·배터리·의약품·전자제품은 별도 수거함이 있어요. 일반쓰레기·재활용 수거함에 넣지 마세요.',
  ),
};
