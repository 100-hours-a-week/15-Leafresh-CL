import http from 'k6/http';
import { check, sleep } from 'k6';

const testType = __ENV.TEST_TYPE || 'load';

export const options = {
  stages: testType === 'stress'
    ? [
        { duration: '30s', target: 100 },
        { duration: '1m', target: 300 },
        { duration: '30s', target: 0 },
      ]
    : [
        { duration: '1m', target: 20 },
        { duration: '2m', target: 50 },
        { duration: '2m', target: 50 },
        { duration: '1m', target: 0 },
      ],
  thresholds: {
    'http_req_failed{type:all}': ['rate<0.20'], // 20% 이상이면 실패 처리
  },
};

const sessionCookie = 'your_session_cookie_name=your_cookie_value';

export default function () {
  const headers = {
    'Cookie': sessionCookie,
    'Content-Type': 'application/json',
  };

  // === FE 요청 ===
  const resFE = http.get('https://leafresh.app/', { headers });
  check(resFE, {
    'FE status is 2xx': (r) => r.status >= 200 && r.status < 300,
  });

  // === BE 요청 1 ===
  const resBE1 = http.get('https://leafresh.app/api/members/challenges/group/creations', { headers });
  check(resBE1, {
    'BE group creations status is 2xx': (r) => r.status >= 200 && r.status < 300,
  });

  // === BE 요청 2 ===
  const resBE2 = http.get('https://leafresh.app/api/members/products/list', { headers });
  check(resBE2, {
    'BE product list status is 2xx': (r) => r.status >= 200 && r.status < 300,
  });

  // === BE 요청 3 ===
  const resBE3 = http.get('https://leafresh.app/api/challenges/group', { headers });
  check(resBE3, {
    'BE challenge group status is 2xx': (r) => r.status >= 200 && r.status < 300,
  });

  // === AI 요청 ===
  const aiPayload = JSON.stringify({
    location: "Seoul",
    workType: "remote",
    category: "development"
  });

  const resAI = http.post('https://leafresh.app/ai/chatbot/recommendation/base-info', aiPayload, { headers });
  check(resAI, {
    'AI recommendation status is 2xx': (r) => r.status >= 200 && r.status < 300,
  });

  sleep(1);
}

