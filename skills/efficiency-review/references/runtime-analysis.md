# Efficiency Review — Runtime Analysis Commands

Use these commands during Phase 3 (runtime analysis) when you need direct measurements of memory, event loop, or pool health on a running system.

```bash
# Analyze runtime memory consumption
node --inspect --expose-gc -e "
const before = process.memoryUsage();
console.log('Heap Used:', Math.round(before.heapUsed / 1024 / 1024), 'MB');
console.log('Heap Total:', Math.round(before.heapTotal / 1024 / 1024), 'MB');
console.log('RSS:', Math.round(before.rss / 1024 / 1024), 'MB');
"

# Check for memory leaks in running process
node --inspect -e "
setInterval(() => {
  const mem = process.memoryUsage();
  console.log(Date.now(), mem.heapUsed / 1024 / 1024);
}, 5000);
" 2>&1 | head -20

# Analyze event loop blocking
node -e "
const { EventEmitter } = require('events');
const emitter = new EventEmitter();
let listeners = emitter.listenerCount('event');
console.log('Event emitter slots:', listeners);
"

# Check database connection pool health
grep -r "pool\|max\|connection" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | grep -i "db\|database\|redis" | head -10
```

## V8 Heap Inspection

```javascript
// Set at entry point
const v8 = require('v8');
console.log('Heap statistics:', v8.getHeapStatistics());
```
