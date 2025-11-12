document.addEventListener('DOMContentLoaded', function() {
    const button = document.getElementById('clickBtn');
    const messageElement = document.getElementById('message');
    
    const messages = [
        'Отлично! Вы нажали кнопку!',
        'Отлично! Вы нажали кнопку!',
        'Еще раз',
        'И еще',
        'Ну похоже, что можно и зачесть'
    ];
    
    let clickCount = 0;
    
    button.addEventListener('click', function() {
        clickCount++;
        const randomMessage = messages[Math.floor(Math.random() * messages.length)];
        messageElement.textContent = `${randomMessage} (Нажатий: ${clickCount})`;
        messageElement.style.animation = 'none';
        setTimeout(() => {
            messageElement.style.animation = 'fadeIn 0.5s ease-in';
        }, 10);
    });
    
    button.style.opacity = '0';
    setTimeout(() => {
        button.style.transition = 'opacity 0.5s ease-in';
        button.style.opacity = '1';
    }, 300);
});
