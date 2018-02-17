#ifndef BOARD_H
#define BOARD_H

#include <QObject>
#include <QQuickItem>
#include <QHash>
#include <QElapsedTimer>
#include <QTimer>
class Square;
class Piece;
class QAESEncryption;
class Board : public QQuickItem
{
    Q_OBJECT

public:
    Board();
    QHash<int, Square*> m_squares;
    Q_INVOKABLE Square* find_square(int row, int col);
    Q_INVOKABLE Square* get_neighbor(Square* i_square, int row_offset, int col_offset);
    Q_INVOKABLE QList<Square*> get_path(Square* i_square, int row_offset, int col_offset, int max_squares);
    Q_INVOKABLE QList<Square*> get_valid_squares(Square* i_square);
    Q_INVOKABLE bool square_has_piece(Square* i_square);
    Q_INVOKABLE bool square_has_enemy(Square* square1, Square* square2);
    Square* selectedSquare;
    Q_INVOKABLE QByteArray serialize();
    Q_INVOKABLE QString boardHash();
    Q_INVOKABLE QString  game_id() { return m_gameid; }
    QString m_gameid;
    int blockSelectionOwner;
    bool m_isWaiting;
    Q_INVOKABLE bool isWaiting() { if (m_isWaiting != false) { return true; } return false; }
    QHash<QString, bool> moveWaitList;
    QHash<QString, QByteArray> moveWaitData;
    bool got_ping;
    Q_INVOKABLE QString req_gameType() { return m_req_gameType; }
    QString m_req_gameType;
   Q_INVOKABLE QString encrypt(QString str);
    QElapsedTimer board_timer;
    Q_INVOKABLE qint64 totalGameMS();
    QTimer attackTimer;
    Q_INVOKABLE QString generateHash(QString param1, QString param2);

signals:
    void changedBoard(QString serial_data);
    void waitChanged();
    void gameOver(int winner);
    void try_reconnect(QString gameId);
    void verify_board(QString board_data);
public slots:
    Q_INVOKABLE void init_square(int row, int col, Square* i_square);
    Q_INVOKABLE void select_square(Square *i_square);
    Q_INVOKABLE void assign_piece(int row, int col, int rank, int player,  bool isNewAssignment = true, QString response_uid = 0);
    Q_INVOKABLE void setGameId(QString newId);
    Q_INVOKABLE void setCurrentOwner(int ownerNum);
    Q_INVOKABLE void unserialize(QVariant i_data, QString response_uid);
    Q_INVOKABLE void stopWaiting(QString assignment_uid) { if (assignment_uid == "") { this->moveWaitList.clear(); } else { this->moveWaitList.remove(assignment_uid); } if (moveWaitList.keys().count() > 0) { m_isWaiting = true; } else { this->m_isWaiting = false; } emit this->waitChanged();  }
    Q_INVOKABLE void randomMove();
    Q_INVOKABLE void checkForPing();
    Q_INVOKABLE void confirmGotPing() { this->got_ping = true; }
    void check_attack_states();
};

#endif // BOARD_H