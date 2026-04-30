const tabs = document.querySelectorAll("[data-slide]");
const slides = document.querySelectorAll("[data-slide-panel]");
let activeSlideIndex = 0;

function setSlide(index) {
  if (!slides.length) return;

  activeSlideIndex = (index + slides.length) % slides.length;
  tabs.forEach((item, itemIndex) => {
    item.classList.toggle("is-active", itemIndex === activeSlideIndex);
  });
  slides.forEach((slide, slideIndex) => {
    slide.classList.toggle("is-active", slideIndex === activeSlideIndex);
  });
}

tabs.forEach((tab) => {
  tab.addEventListener("click", () => {
    setSlide(Number(tab.dataset.slide));
  });
});

if (slides.length > 1) {
  setInterval(() => {
    setSlide(activeSlideIndex + 1);
  }, 5200);
}

document.querySelectorAll("[data-open]").forEach((trigger) => {
  trigger.addEventListener("click", () => {
    const modal = document.getElementById(trigger.dataset.open);
    if (modal && typeof modal.showModal === "function") {
      modal.showModal();
    }
  });
});

const articles = [
  {
    title: "二手手机回收价格如何更稳定",
    body:
      "稳定价格的核心不只是看型号和成色，还要把检测标准、渠道供需、历史成交和风险识别纳入同一套判断。乐回收SaaS通过智能检测与AI估价，帮助门店和回收商减少经验偏差，让交易利润更客观。",
  },
  {
    title: "门店回收业务数字化提效路径",
    body:
      "门店回收效率通常卡在检测、报价、履约和结算的衔接上。通过一站式流程管理，门店可以把设备信息、订单状态和结算进度统一沉淀，缩短周转周期，提升服务体验。",
  },
  {
    title: "回收商如何构建稳定货源网络",
    body:
      "稳定货源来自持续的区域连接和可信交易关系。平台通过3000+回收商网络、商家覆盖和风险预测模型，帮助回收商更快匹配设备、识别异常交易，并形成长期经营能力。",
  },
];

const articleModal = document.getElementById("articleModal");
const articleTitle = document.getElementById("articleTitle");
const articleBody = document.getElementById("articleBody");

document.querySelectorAll("[data-article]").forEach((card) => {
  const openArticle = () => {
    const article = articles[Number(card.dataset.article)];
    articleTitle.textContent = article.title;
    articleBody.textContent = article.body;
    if (typeof articleModal.showModal === "function") {
      articleModal.showModal();
    }
  };

  card.addEventListener("click", openArticle);
  card.addEventListener("keydown", (event) => {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      openArticle();
    }
  });
});

document.querySelector("[data-close-article]")?.addEventListener("click", () => {
  articleModal.close();
});

document.querySelectorAll(".modal").forEach((modal) => {
  modal.addEventListener("click", (event) => {
    if (event.target === modal) {
      modal.close();
    }
  });
});
