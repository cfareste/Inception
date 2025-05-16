const crossEmoji = "❌";
const pointEmoji = "⭕";
const gameButton = document.getElementById('gameBtn');
const board = document.getElementById('board');
const cellsCollection = document.getElementsByClassName('cell');
const cellsArray = [...cellsCollection];
var inGame = false;
var isCrossPlayerTurn = true;

function checkCell(e) {
    let cell = e.srcElement;
    let symbol = (isCrossPlayerTurn) ? crossEmoji : pointEmoji;

    if (cell.innerHTML == crossEmoji || cell.innerHTML == pointEmoji)
        return ;

    cell.innerHTML = symbol;
    isCrossPlayerTurn = !isCrossPlayerTurn;
}

function startGame() {
    cellsArray.forEach(cell => {
        cell.addEventListener('click', checkCell)
    });
    board.classList.remove('disabled');
}

function disableBoard() {
    board.classList.add('disabled');
}

function restartGame() {
    cellsArray.forEach(cell => {
        cell.innerHTML = "";
        cell.removeEventListener('click', checkCell)
    });
    let spanChild = document.createElement("span");
    spanChild.innerHTML = "Tac";
    spanChild.classList.add("tac");
    document.getElementById('cell-3').innerHTML = "Tic";
    document.getElementById('cell-4').appendChild(spanChild);
    document.getElementById('cell-5').innerHTML = "Toe";
    setTimeout(disableBoard, 0);
}

gameButton.addEventListener('click', () => {
    let buttonText = "";

    inGame = !inGame;
    if (inGame) {
        startGame();
        buttonText = "Restart Game";
    } else {
        restartGame();
        buttonText = "Start Game";
    }

    gameButton.innerHTML = buttonText;
});
