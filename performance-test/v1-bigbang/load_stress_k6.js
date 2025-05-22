import http from 'k6/http';
import { check, sleep } from 'k6';

const testType = __ENV.TEST_TYPE || 'load';
const sessionCookie = 'your_session_cookie_name=your_cookie_value';
const headers = {
  'Cookie': sessionCookie,
  'Content-Type': 'application/json',
};

// 공통 요청 함수
function performRequests() {
  // === FE 요청 ===
  const resFE = http.get('https://leafresh.app/', { headers });
  check(resFE, { 'FE status is 2xx': (r) => r.status >= 200 && r.status < 300 });

  // === BE 요청 1 ===
  const resBE1 = http.get('https://leafresh.app/api/members/challenges/group/creations', { headers });
  check(resBE1, { 'BE group creations status is 2xx': (r) => r.status >= 200 && r.status < 300 });

  // === BE 요청 2 ===
  const resBE2 = http.get('https://leafresh.app/api/members/products/list', { headers });
  check(resBE2, { 'BE product list status is 2xx': (r) => r.status >= 200 && r.status < 300 });

  // === BE 요청 3 ===
  const resBE3 = http.get('https://leafresh.app/api/challenges/group', { headers });
  check(resBE3, { 'BE challenge group status is 2xx': (r) => r.status >= 200 && r.status < 300 });

  // === AI 요청 ===
  const aiPayload = JSON.stringify({ location: "Seoul", workType: "remote", category: "development" });
  const resAI = http.post('https://leafresh.app/ai/chatbot/recommendation/base-info', aiPayload, { headers });
  check(resAI, { 'AI recommendation status is 2xx': (r) => r.status >= 200 && r.status < 300 });

  sleep(1);
}

export const options = {
  scenarios: {
    loadTest: {
      exec: 'performRequests',
      executor: 'ramping-vus',
      startVUs: 10,
      stages: [
        { duration: '2m', target: 100 },
        { duration: '5m', target: 200 },
        { duration: '5m', target: 400 },
        { duration: '5m', target: 600 },
        { duration: '5m', target: 800 },
        { duration: '5m', target: 1000 },
        { duration: '3m', target: 1000 },
        { duration: '2m', target: 0 },
      ],
      thresholds: {
        'http_req_failed{scenario:loadTest}': ['rate<0.05'],
        'http_req_duration{scenario:loadTest}': ['p(95)<500', 'p(99)<1000'],
      },
    },
    stressTest: {
      exec: 'performRequests',
      executor: 'ramping-vus',
      startVUs: 50,
      stages: [
        { duration: '30s', target: 100 },
        { duration: '1m', target: 300 },
        { duration: '30s', target: 0 },
      ],
      thresholds: {
        'http_req_failed{scenario:stressTest}': ['rate<0.10'], // 스트레스 테스트는 실패율 허용 범위 증가
        'http_req_duration{scenario:stressTest}': ['p(95)<800', 'p(99)<1500'], // 스트레스 테스트는 응답 시간 허용 범위 증가
      },
    },
  },
};
