[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$wordsJsonPath = Join-Path $PSScriptRoot "words_180.json"
$wordsJson = Get-Content $wordsJsonPath -Raw -Encoding UTF8
$wordsObj = $wordsJson | ConvertFrom-Json

# Generate JS array string
$jsArrayLines = @()
foreach ($w in $wordsObj) {
    $enEsc = $w.en.Replace('"', '\"')
    $kanaEsc = $w.kana.Replace('"', '\"')
    $jaEsc = $w.ja.Replace('"', '\"')
    $jsArrayLines += "            { id: $($w.id), en: `"$enEsc`", kana: `"$kanaEsc`", ja: `"$jaEsc`", mistakes: 0, history: [] }"
}
$jsWordListStr = $jsArrayLines -join ",`n"

$htmlContent = @"
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>中学1年 英単語帳 (180問版)</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        rindou: {
                            50: '#F7F5FA',
                            100: '#EEEAF5',
                            200: '#DCCFEA',
                            300: '#C5B1DC',
                            400: '#A98FCD',
                            500: '#8A6BB3', // リンドウ色
                            600: '#7656A0',
                            700: '#614287',
                            800: '#4D326F',
                            900: '#382253'
                        }
                    }
                }
            }
        }
    </script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=M+PLUS+Rounded+1c:wght@400;700;800&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', 'M PLUS Rounded 1c', sans-serif;
            background-color: #F7F5FA;
        }
        .perspective { perspective: 1000px; }
        .preserve-3d { transform-style: preserve-3d; }
        .backface-hidden { backface-visibility: hidden; }
        .rotate-y-180 { transform: rotateY(180deg); }
        .transition-transform {
            transition-property: transform;
            transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
            transition-duration: 450ms;
        }
    </style>
</head>
<body class="text-gray-800 flex flex-col min-h-screen">

    <header class="bg-white shadow-sm p-4 text-center relative border-b border-rindou-100">
        <div class="inline-block px-3 py-1 bg-rindou-100 text-rindou-700 text-xs font-bold rounded-full mb-1">
            🌸 すずちゃん専用 中学英語マスター
        </div>
        <h1 class="text-2xl md:text-3xl font-bold text-gray-800 tracking-tight">中学1年 英単語帳 <span class="text-rindou-600 text-lg md:text-xl font-normal">(全180問)</span></h1>
        
        <div class="mt-3 flex flex-wrap justify-center items-center gap-2 text-xs md:text-sm text-gray-600 bg-rindou-50 p-2 rounded-xl max-w-xl mx-auto border border-rindou-200">
            <span class="font-semibold text-rindou-800 flex items-center">
                <svg class="w-4 h-4 mr-1 inline text-rindou-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 0115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path></svg>
                同期コード:
            </span>
            <input type="text" id="sync-code-input" class="px-2 py-1 border border-rindou-300 rounded text-center font-mono font-bold w-32 focus:outline-none focus:ring-2 focus:ring-rindou-500 bg-white" placeholder="合言葉" />
            <button onclick="changeSyncCode()" class="px-3 py-1 bg-rindou-500 text-white rounded-lg font-medium hover:bg-rindou-600 transition-colors shadow-sm">同期設定</button>
            <span id="sync-status" class="ml-2 text-xs font-medium text-emerald-600 flex items-center hidden">
                <span class="w-2 h-2 bg-emerald-500 rounded-full mr-1 animate-pulse"></span> 同期中
            </span>
        </div>
    </header>

    <main class="flex-grow container mx-auto p-4 flex flex-col items-center max-w-3xl">
        
        <div class="flex flex-col md:flex-row w-full justify-between items-center mb-6 gap-4">
            <div class="flex space-x-3">
                <button id="tab-flashcard" class="px-5 py-2.5 bg-rindou-500 text-white rounded-xl shadow-sm font-bold focus:outline-none focus:ring-2 focus:ring-rindou-400 transition-all hover:bg-rindou-600" onclick="switchTab('flashcard')">単語帳モード</button>
                <button id="tab-list" class="px-5 py-2.5 bg-white text-gray-700 border border-gray-200 rounded-xl shadow-sm font-bold hover:bg-rindou-50 hover:text-rindou-700 focus:outline-none focus:ring-2 focus:ring-rindou-300 transition-all" onclick="switchTab('list')">間違えた単語一覧</button>
            </div>
            <button onclick="initiateReset()" class="px-4 py-2 bg-red-50 text-red-600 border border-red-200 rounded-xl shadow-sm font-semibold hover:bg-red-100 focus:outline-none focus:ring-2 focus:ring-red-400 flex items-center transition-colors text-sm">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd" d="M4 2a1 1 0 011 1v2.101a7.002 7.002 0 0111.601 2.566 1 1 0 11-1.885.666A5.002 5.002 0 005.999 7H9a1 1 0 010 2H4a1 1 0 01-1-1V3a1 1 0 011-1zm.008 9.057a1 1 0 011.276.61A5.002 5.002 0 0014.001 13H11a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0v-2.101a7.002 7.002 0 01-11.601-2.566 1 1 0 01.61-1.276z" clip-rule="evenodd" />
                </svg>
                履歴リセット
            </button>
        </div>

        <div id="flashcard-area" class="w-full flex flex-col items-center">
            
            <div class="flex justify-center gap-2 mb-4 bg-rindou-100 p-1.5 rounded-full shadow-inner">
                <button id="mode-all-btn" class="px-6 py-2 rounded-full font-bold text-sm bg-white text-rindou-700 shadow-sm transition-all duration-200" onclick="setMode('all')">全問モード</button>
                <button id="mode-review-btn" class="px-6 py-2 rounded-full font-bold text-sm text-gray-500 hover:text-rindou-700 transition-all duration-200" onclick="setMode('review')">復習モード (×のみ)</button>
            </div>

            <div class="mb-4 text-gray-500 font-medium text-sm flex gap-4">
                <span>出題: <span id="current-index-display" class="font-bold text-rindou-700">1</span> / <span id="total-words-display">0</span>問</span>
                <span class="border-l border-gray-300 pl-4">現在の連続学習: <span id="session-count-display" class="font-bold text-rindou-600">0</span>問</span>
            </div>

            <div class="flex flex-col md:flex-row items-center justify-center w-full max-w-2xl gap-6">
                
                <div class="relative w-full max-w-md aspect-[4/3] perspective cursor-pointer select-none" id="flashcard" onclick="flipCard()">
                    <div id="card-inner" class="w-full h-full relative preserve-3d transition-transform">
                        
                        <!-- 表面 -->
                        <div class="absolute w-full h-full bg-white rounded-3xl shadow-lg flex flex-col items-center justify-center backface-hidden border-2 border-rindou-100 p-6 hover:border-rindou-300 transition-colors">
                            <div id="front-mistake-count" class="absolute top-4 right-4 text-red-500 font-bold bg-red-50 px-2.5 py-1 rounded-full text-xs hidden border border-red-100">
                                × <span id="front-mistake-number">0</span>
                            </div>
                            <h2 id="word-en" class="text-4xl md:text-5xl font-bold mb-3 text-center break-all text-gray-800 tracking-tight"></h2>
                            <p id="word-kana" class="text-lg md:text-xl text-rindou-400 text-center font-medium"></p>
                        </div>

                        <!-- 裏面 -->
                        <div class="absolute w-full h-full bg-white rounded-3xl shadow-lg flex flex-col items-center justify-center backface-hidden rotate-y-180 border-2 border-rindou-300 p-6 bg-gradient-to-b from-white to-rindou-50/40">
                            <div id="back-mistake-count" class="absolute top-4 right-4 text-red-500 font-bold bg-red-50 px-2.5 py-1 rounded-full text-xs hidden border border-red-100">
                                × <span id="back-mistake-number">0</span>
                            </div>
                            <h3 class="text-xs font-bold text-rindou-500 mb-3 uppercase tracking-wider bg-rindou-100 px-3 py-1 rounded-full">日本語の意味</h3>
                            <p id="word-ja" class="text-2xl md:text-3xl font-bold text-center text-gray-800 leading-relaxed px-4"></p>
                        </div>
                    </div>
                </div>

                <div class="flex flex-row md:flex-col gap-4 justify-center items-center shrink-0 w-full md:w-auto">
                    <button id="flip-btn" onclick="flipCard()" class="w-16 h-16 md:w-20 md:h-20 bg-white border-2 border-rindou-200 rounded-2xl flex items-center justify-center shadow-md hover:bg-rindou-50 hover:border-rindou-400 focus:outline-none focus:ring-4 focus:ring-rindou-200 text-rindou-600 transition-all" title="めくる (Enter)">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 md:h-10 md:w-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                        </svg>
                    </button>
                    
                    <div id="judgment-controls" class="flex gap-4 md:flex-col hidden absolute md:relative z-10 md:z-auto">
                        <button onclick="judge(true, event)" class="w-16 h-16 md:w-20 md:h-20 rounded-2xl bg-emerald-50 border-2 border-emerald-300 text-emerald-600 text-4xl font-bold shadow-md hover:bg-emerald-100 hover:scale-105 focus:outline-none focus:ring-4 focus:ring-emerald-200 flex items-center justify-center transition-all" title="正解">
                            〇
                        </button>
                        <button onclick="judge(false, event)" class="w-16 h-16 md:w-20 md:h-20 rounded-2xl bg-rose-50 border-2 border-rose-300 text-rose-600 text-4xl font-bold shadow-md hover:bg-rose-100 hover:scale-105 focus:outline-none focus:ring-4 focus:ring-rose-200 flex items-center justify-center transition-all" title="不正解">
                            ×
                        </button>
                    </div>
                </div>
            </div>
            
            <p class="mt-6 text-xs md:text-sm text-gray-400 font-medium">※カードをタップ、または [Enter] キーでめくります</p>
        </div>

        <div id="list-area" class="w-full hidden flex-col items-center">
            <h2 class="text-xl font-bold mb-4 text-gray-800">×がついた単語一覧</h2>
            <div class="w-full overflow-x-auto bg-white rounded-2xl shadow-sm border border-rindou-100">
                <table class="min-w-full leading-normal">
                    <thead>
                        <tr>
                            <th class="px-5 py-4 border-b-2 border-rindou-100 bg-rindou-50 text-left text-xs font-bold text-rindou-800 uppercase tracking-wider cursor-pointer hover:bg-rindou-100 transition-colors" onclick="sortTable('en')">
                                単語 <span id="sort-icon-en" class="ml-1 text-gray-400"></span>
                            </th>
                            <th class="px-5 py-4 border-b-2 border-rindou-100 bg-rindou-50 text-left text-xs font-bold text-rindou-800 uppercase tracking-wider cursor-pointer hover:bg-rindou-100 transition-colors" onclick="sortTable('ja')">
                                意味 <span id="sort-icon-ja" class="ml-1 text-gray-400"></span>
                            </th>
                            <th class="px-5 py-4 border-b-2 border-rindou-100 bg-rindou-50 text-left text-xs font-bold text-rindou-800 uppercase tracking-wider cursor-pointer hover:bg-rindou-100 transition-colors" onclick="sortTable('mistakes')">
                                履歴 (直近5回) <span id="sort-icon-mistakes" class="ml-1 text-rindou-600">▼</span>
                            </th>
                        </tr>
                    </thead>
                    <tbody id="mistake-list-body">
                    </tbody>
                </table>
            </div>
            <div id="no-mistakes-msg" class="mt-8 text-rindou-700 font-bold bg-rindou-50 px-6 py-4 rounded-2xl border border-rindou-200 hidden shadow-sm text-center">
                ✨ ×がついた単語はありません！とっても素晴らしい！🎉
            </div>
        </div>

        <div id="unified-modal" class="fixed inset-0 bg-gray-900 bg-opacity-60 flex items-center justify-center z-50 hidden backdrop-blur-sm transition-opacity">
            <div class="bg-white rounded-3xl shadow-2xl p-8 w-11/12 max-w-sm transform transition-all scale-100 border border-rindou-100">
                <h3 id="modal-title" class="text-2xl font-bold text-gray-800 mb-4 text-center hidden"></h3>
                <p id="modal-message" class="text-lg font-medium text-gray-600 mb-8 text-center leading-relaxed"></p>
                <div id="modal-btn-container" class="flex flex-col gap-3">
                    <button id="modal-btn-primary" class="w-full py-3 bg-rindou-500 text-white rounded-xl hover:bg-rindou-600 focus:outline-none focus:ring-4 focus:ring-rindou-300 font-bold transition-all text-lg shadow-sm">
                        プライマリ
                    </button>
                    <button id="modal-btn-secondary" class="w-full py-3 bg-gray-100 text-gray-700 rounded-xl hover:bg-gray-200 focus:outline-none focus:ring-4 focus:ring-gray-300 font-bold transition-all shadow-sm hidden">
                        セカンダリ
                    </button>
                </div>
            </div>
        </div>

    </main>

    <script type="module">
        import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
        import { getAuth, signInAnonymously, signInWithCustomToken } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";
        import { getFirestore, doc, getDoc, setDoc, onSnapshot } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js";

        // --- 中学1年生向け 厳選180単語データ ---
        const initialWordList = [
$jsWordListStr
        ];

        let wordData = [...initialWordList];
        
        let learningMode = 'all'; 
        
        let orderStates = {
            all: { indices: [], currentIndex: 0 },
            review: { indices: [], currentIndex: 0 }
        };
        
        let sessionCount = 0; 
        const SESSION_LIMIT = 30; // 30問で区切る

        let isFlipped = false;
        let currentSort = { key: 'mistakes', order: 'desc' };
        let unsubscribe = null;
        let syncCode = localStorage.getItem('suzu_flashcards_sync_code') || 'suzu';
        let isSyncing = false; 

        // 息子さんのアプリとデータが混ざらないよう、専用のappIdとコレクション名を使用
        const appId = typeof __app_id !== 'undefined' ? __app_id : 'flashcards-suzu-jh1-180';
        const firebaseConfig = typeof __firebase_config !== 'undefined' 
            ? JSON.parse(__firebase_config) 
            : {
                apiKey: "AIzaSyDemoKeyOnlyForFallback123456",
                authDomain: "demo-app.firebaseapp.com",
                projectId: "demo-app",
                storageBucket: "demo-app.appspot.com",
                messagingSenderId: "1234567890",
                appId: "1:1234567890:web:1234567890"
            };

        const app = initializeApp(firebaseConfig);
        const auth = getAuth(app);
        const db = getFirestore(app);

        async function setupCloudSync() {
            try {
                if (typeof __initial_auth_token !== 'undefined' && __initial_auth_token) {
                    await signInWithCustomToken(auth, __initial_auth_token);
                } else {
                    await signInAnonymously(auth);
                }
                document.getElementById('sync-code-input').value = syncCode;
                subscribeToSyncData();
            } catch (err) {
                console.warn("Cloud sync init failed, fallback to local:", err);
                loadLocalData();
            }
        }

        function subscribeToSyncData() {
            if (unsubscribe) unsubscribe();

            const syncDocRef = doc(db, 'artifacts', appId, 'public', 'data', 'flashcard_progress_suzu_180', syncCode);
            document.getElementById('sync-status').classList.remove('hidden');

            unsubscribe = onSnapshot(syncDocRef, (docSnap) => {
                isSyncing = true;
                if (docSnap.exists()) {
                    const data = docSnap.data();
                    
                    if (data.progress) {
                        wordData = initialWordList.map(item => {
                            const saved = data.progress.find(p => p.id === item.id);
                            return saved ? { ...item, mistakes: saved.mistakes || 0, history: saved.history || [] } : item;
                        });
                    }

                    if (data.orderStates && data.orderStates.all.indices.length === wordData.length) {
                        orderStates = data.orderStates;
                    } else if (data.orderState && data.orderState.shuffledIndices) {
                        orderStates.all.indices = data.orderState.shuffledIndices;
                        orderStates.all.currentIndex = data.orderState.currentOrderIndex || 0;
                    } else {
                        if (orderStates.all.indices.length === 0) initShuffle('all');
                    }
                    
                    if (learningMode === 'review' && wordData.filter(w => w.mistakes > 0).length === 0) {
                        learningMode = 'all';
                        updateModeUI();
                    }

                } else {
                    if (orderStates.all.indices.length === 0) initShuffle('all');
                    saveCloudData();
                }
                showCard();
                updateList();
                isSyncing = false;
            }, (error) => {
                console.error("Firestore sync error:", error);
                isSyncing = false;
            });
        }

        async function saveCloudData() {
            if (!auth.currentUser || isSyncing) return;
            
            const progress = wordData
                .filter(w => w.mistakes > 0 || w.history.length > 0)
                .map(w => ({ id: w.id, mistakes: w.mistakes, history: w.history }));
                
            const syncDocRef = doc(db, 'artifacts', appId, 'public', 'data', 'flashcard_progress_suzu_180', syncCode);
            
            try {
                await setDoc(syncDocRef, { progress, orderStates, updatedAt: new Date().toISOString() }, { merge: true });
            } catch (err) {
                console.error("Failed to save to cloud:", err);
            }
        }

        function loadLocalData() {
            if (orderStates.all.indices.length === 0) initShuffle('all');
            showCard();
        }

        window.changeSyncCode = function() {
            const inputVal = document.getElementById('sync-code-input').value.trim();
            if (!inputVal) return;
            syncCode = inputVal;
            localStorage.setItem('suzu_flashcards_sync_code', syncCode);
            subscribeToSyncData();
        };

        const cardInner = document.getElementById('card-inner');
        const wordEnEl = document.getElementById('word-en');
        const wordKanaEl = document.getElementById('word-kana');
        const wordJaEl = document.getElementById('word-ja');
        const frontMistakeCountEl = document.getElementById('front-mistake-count');
        const frontMistakeNumberEl = document.getElementById('front-mistake-number');
        const backMistakeCountEl = document.getElementById('back-mistake-count');
        const backMistakeNumberEl = document.getElementById('back-mistake-number');
        const judgmentControlsEl = document.getElementById('judgment-controls');
        const currentIndexDisplay = document.getElementById('current-index-display');
        const totalWordsDisplay = document.getElementById('total-words-display');
        const sessionCountDisplay = document.getElementById('session-count-display');

        function initShuffle(mode) {
            let indices = [];
            if (mode === 'all') {
                indices = Array.from({ length: wordData.length }, (_, i) => i);
            } else if (mode === 'review') {
                wordData.forEach((w, i) => { if (w.mistakes > 0) indices.push(i); });
            }

            for (let i = indices.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                [indices[i], indices[j]] = [indices[j], indices[i]];
            }
            orderStates[mode].indices = indices;
            orderStates[mode].currentIndex = 0;
        }

        function updateModeUI() {
            const btnAll = document.getElementById('mode-all-btn');
            const btnReview = document.getElementById('mode-review-btn');
            
            if (learningMode === 'all') {
                btnAll.className = "px-6 py-2 rounded-full font-bold text-sm bg-white text-rindou-700 shadow-sm transition-all duration-200";
                btnReview.className = "px-6 py-2 rounded-full font-bold text-sm text-gray-500 hover:text-rindou-700 transition-all duration-200";
            } else {
                btnReview.className = "px-6 py-2 rounded-full font-bold text-sm bg-white text-rose-600 shadow-sm transition-all duration-200";
                btnAll.className = "px-6 py-2 rounded-full font-bold text-sm text-gray-500 hover:text-rindou-700 transition-all duration-200";
            }
        }

        window.setMode = function(mode) {
            if (mode === 'review') {
                const hasMistakes = wordData.some(w => w.mistakes > 0);
                if (!hasMistakes) {
                    showModal('alert', '×がついた単語がありません。素晴らしい！🎉', 'OK', closeModal);
                    return;
                }
            }
            
            learningMode = mode;
            updateModeUI();
            
            if (orderStates[mode].indices.length === 0) {
                initShuffle(mode);
            }
            
            showCard();
        };

        function showCard() {
            const state = orderStates[learningMode];
            if (state.indices.length === 0) return;
            
            const realIndex = state.indices[state.currentIndex];
            const word = wordData[realIndex];
            
            wordEnEl.textContent = word.en;
            wordKanaEl.textContent = word.kana;
            wordJaEl.textContent = word.ja;
            
            if (word.en.length > 15) {
                wordEnEl.classList.replace('text-4xl', 'text-2xl');
                wordEnEl.classList.replace('md:text-5xl', 'md:text-3xl');
            } else {
                wordEnEl.classList.replace('text-2xl', 'text-4xl');
                wordEnEl.classList.replace('md:text-3xl', 'md:text-5xl');
            }

            currentIndexDisplay.textContent = state.currentIndex + 1;
            totalWordsDisplay.textContent = state.indices.length;
            sessionCountDisplay.textContent = sessionCount;

            if (word.mistakes > 0) {
                frontMistakeNumberEl.textContent = word.mistakes;
                backMistakeNumberEl.textContent = word.mistakes;
                frontMistakeCountEl.classList.remove('hidden');
                backMistakeCountEl.classList.remove('hidden');
            } else {
                frontMistakeCountEl.classList.add('hidden');
                backMistakeCountEl.classList.add('hidden');
            }

            if (isFlipped) {
                cardInner.classList.remove('rotate-y-180');
                isFlipped = false;
            }
            judgmentControlsEl.classList.add('hidden');
            document.getElementById('flip-btn').classList.remove('hidden');
        }

        window.flipCard = function() {
            isFlipped = !isFlipped;
            if (isFlipped) {
                cardInner.classList.add('rotate-y-180');
                document.getElementById('flip-btn').classList.add('hidden');
                setTimeout(() => {
                    judgmentControlsEl.classList.remove('hidden');
                }, 150);
            }
        };

        window.judge = function(isCorrect, event) {
            event.stopPropagation(); 

            const state = orderStates[learningMode];
            const realIndex = state.indices[state.currentIndex];
            const word = wordData[realIndex];
            
            // 直近5回分の履歴のみ保持
            const historyMark = isCorrect ? '〇' : '×';
            word.history.push(historyMark);
            if (word.history.length > 5) {
                word.history.shift();
            }

            if (!isCorrect) {
                word.mistakes += 1;
            }

            sessionCount++;
            
            state.currentIndex++;
            if (state.currentIndex >= state.indices.length) {
                initShuffle(learningMode); 
            }
            
            saveCloudData();

            // 30問区切り
            if (sessionCount >= SESSION_LIMIT) {
                showModal('session', `🎉 ${SESSION_LIMIT}問クリアしました！\nすずちゃん、お疲れ様！少し休憩しますか？`, 'このまま続ける', () => {
                    sessionCount = 0;
                    closeModal();
                    showCard();
                }, '休んで一覧を見る', () => {
                    sessionCount = 0;
                    closeModal();
                    switchTab('list');
                });
            } else {
                showCard();
            }
        };

        document.addEventListener('keydown', function(event) {
            if (document.getElementById('flashcard-area').classList.contains('hidden')) return;
            if (document.getElementById('unified-modal').classList.contains('hidden') === false) return;
            if (event.key === 'Enter') {
                event.preventDefault();
                if (isFlipped) return; 
                flipCard();
            }
        });

        window.switchTab = function(tabId) {
            const flashcardArea = document.getElementById('flashcard-area');
            const listArea = document.getElementById('list-area');
            const tabFlashcard = document.getElementById('tab-flashcard');
            const tabList = document.getElementById('tab-list');

            if (tabId === 'flashcard') {
                flashcardArea.classList.remove('hidden');
                flashcardArea.classList.add('flex');
                listArea.classList.add('hidden');
                listArea.classList.remove('flex');
                
                tabFlashcard.classList.replace('bg-white', 'bg-rindou-500');
                tabFlashcard.classList.replace('text-gray-700', 'text-white');
                tabFlashcard.classList.remove('border', 'border-gray-200');
                tabList.classList.replace('bg-rindou-500', 'bg-white');
                tabList.classList.replace('text-white', 'text-gray-700');
                tabList.classList.add('border', 'border-gray-200');
                showCard();
            } else {
                flashcardArea.classList.add('hidden');
                flashcardArea.classList.remove('flex');
                listArea.classList.remove('hidden');
                listArea.classList.add('flex');

                tabList.classList.replace('bg-white', 'bg-rindou-500');
                tabList.classList.replace('text-gray-700', 'text-white');
                tabList.classList.remove('border', 'border-gray-200');
                tabFlashcard.classList.replace('bg-rindou-500', 'bg-white');
                tabFlashcard.classList.replace('text-white', 'text-gray-700');
                tabFlashcard.classList.add('border', 'border-gray-200');
                
                updateList();
            }
        };

        function updateList() {
            const tbody = document.getElementById('mistake-list-body');
            const noMsg = document.getElementById('no-mistakes-msg');
            tbody.innerHTML = '';

            let mistakeWords = wordData.filter(word => word.mistakes > 0);

            if (mistakeWords.length === 0) {
                document.querySelector('table').classList.add('hidden');
                noMsg.classList.remove('hidden');
                return;
            } else {
                document.querySelector('table').classList.remove('hidden');
                noMsg.classList.add('hidden');
            }

            mistakeWords.sort((a, b) => {
                let valA = a[currentSort.key];
                let valB = b[currentSort.key];
                
                if (currentSort.key === 'mistakes') {
                    return currentSort.order === 'asc' ? valA - valB : valB - valA;
                } else {
                    if (valA < valB) return currentSort.order === 'asc' ? -1 : 1;
                    if (valA > valB) return currentSort.order === 'asc' ? 1 : -1;
                    return 0;
                }
            });

            ['en', 'ja', 'mistakes'].forEach(key => {
                document.getElementById(`sort-icon-${key}`).textContent = '';
            });
            document.getElementById(`sort-icon-${currentSort.key}`).textContent = currentSort.order === 'asc' ? '▲' : '▼';

            mistakeWords.forEach(word => {
                const tr = document.createElement('tr');
                tr.className = "border-b border-rindou-100 hover:bg-rindou-50/50 transition-colors";
                
                const historyHtml = word.history.map(mark => 
                    mark === '〇' ? '<span class="text-emerald-500 font-bold mx-1">〇</span>' : '<span class="text-rose-500 font-bold mx-1">×</span>'
                ).join('');

                tr.innerHTML = `
                    <td class="px-5 py-4 text-sm font-bold text-gray-800">${word.en} <span class="text-xs font-normal text-rindou-400 ml-1">${word.kana}</span></td>
                    <td class="px-5 py-4 text-sm text-gray-600">${word.ja}</td>
                    <td class="px-5 py-4 text-sm">
                        <div class="font-bold text-rose-500 mb-1">累計: × ${word.mistakes}回</div>
                        <div class="text-xs bg-rindou-50 p-1.5 rounded-lg inline-block border border-rindou-200">
                            最近: ${historyHtml || '<span class="text-gray-400">記録なし</span>'}
                        </div>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        }

        window.sortTable = function(key) {
            if (currentSort.key === key) {
                currentSort.order = currentSort.order === 'asc' ? 'desc' : 'asc';
            } else {
                currentSort.key = key;
                currentSort.order = key === 'mistakes' ? 'desc' : 'asc';
            }
            updateList();
        };

        function showModal(type, message, btn1Text, btn1Action, btn2Text = null, btn2Action = null) {
            const modal = document.getElementById('unified-modal');
            const msgEl = document.getElementById('modal-message');
            const btn1 = document.getElementById('modal-btn-primary');
            const btn2 = document.getElementById('modal-btn-secondary');
            
            msgEl.innerHTML = message.replace(/\n/g, '<br>');
            
            btn1.textContent = btn1Text;
            btn1.onclick = btn1Action;
            
            if (btn2Text) {
                btn2.textContent = btn2Text;
                btn2.classList.remove('hidden');
                btn2.onclick = btn2Action;
            } else {
                btn2.classList.add('hidden');
            }
            
            if (type === 'danger') {
                btn1.className = "w-full py-3 bg-rose-600 text-white rounded-xl hover:bg-rose-700 focus:outline-none focus:ring-4 focus:ring-rose-300 font-bold transition-all text-lg shadow-sm";
            } else {
                btn1.className = "w-full py-3 bg-rindou-500 text-white rounded-xl hover:bg-rindou-600 focus:outline-none focus:ring-4 focus:ring-rindou-300 font-bold transition-all text-lg shadow-sm";
            }
            
            modal.classList.remove('hidden');
        }

        window.closeModal = function() {
            document.getElementById('unified-modal').classList.add('hidden');
        };

        window.initiateReset = function() {
            showModal('danger', 'すべての単語の正誤履歴をリセットしてよろしいですか？\nこの操作は元に戻せません。', 'はい、リセットします', () => {
                showModal('danger', '本当にリセットしてよろしいですか？\n（合言葉が同じ端末の履歴も消えます）', '最終確認：リセットする', () => {
                    executeReset();
                    closeModal();
                }, 'キャンセル', closeModal);
            }, 'キャンセル', closeModal);
        };

        function executeReset() {
            wordData.forEach(word => {
                word.mistakes = 0;
                word.history = [];
            });
            sessionCount = 0;
            learningMode = 'all';
            updateModeUI();
            initShuffle('all');
            initShuffle('review');
            saveCloudData();
            showCard();
            if(!document.getElementById('list-area').classList.contains('hidden')){
                updateList();
            }
        }

        window.onload = function() {
            totalWordsDisplay.textContent = wordData.length;
            setupCloudSync();
        };
    </script>
</body>
</html>
"@

$htmlPath = Join-Path $PSScriptRoot "index.html"
[System.IO.File]::WriteAllText($htmlPath, $htmlContent, [System.Text.Encoding]::UTF8)
Write-Host "Generated index.html successfully at $htmlPath"
