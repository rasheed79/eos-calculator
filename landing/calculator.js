(function (global) {
  function calcEndOfService(salary, years, months, reason) {
    if (!salary || salary <= 0) return { total: 0, base: 0, result: 0 };
    const total = years + (months / 12.0);
    let base = total <= 5
      ? total * (salary / 2)
      : 5 * (salary / 2) + (total - 5) * salary;
    let result = base;
    if (reason === 'resignation') {
      if (total < 2)       result = 0;
      else if (total < 5)  result = base / 3;
      else if (total < 10) result = (base * 2) / 3;
    }
    return { total, base, result };
  }

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = { calcEndOfService };
  } else {
    global.calcEndOfService = calcEndOfService;
  }
})(typeof globalThis !== 'undefined' ? globalThis : this);
