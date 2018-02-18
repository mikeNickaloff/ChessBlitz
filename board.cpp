#include "board.h"
#include "square.h"
#include "piece.h"
#include "qaesencryption.h"
#include <QtDebug>
#include <QString>
#include <QCryptographicHash>
#include <QUuid>
#include <QDataStream>
#include <QSettings>
#include <QRandomGenerator64>
#include <QDateTime>
#include <QTimer>
Board::Board()
{
    this->m_isWaiting = true;
    got_ping = true;
    this->m_req_gameType = "NONE";
    this->board_timer.start();
    this->connect(&attackTimer, SIGNAL(timeout()), this, SLOT(check_attack_states()));
    attackTimer.start(300);
}

Square *Board::find_square(int row, int col)
{
    int idx = ((row * 10) + col);
    if (m_squares.keys().contains(idx)) {
        return m_squares.value(idx);
    } else {

    }
    return 0;
}

Square *Board::get_neighbor(Square *i_square, int row_offset, int col_offset)
{
    Square* rez = find_square(i_square->row() + row_offset, i_square->col() + col_offset);
    if (rez != 0) {
        return rez;
    }
    return 0;
}

QList<Square *> Board::get_path(Square *i_square, int row_offset, int col_offset, int max_squares)
{
    QList<Square*> rv;
    Square* cur_square = i_square;
    int moves_made = 0;
    while (moves_made < max_squares) {
        Square* tmp_square = get_neighbor(cur_square, row_offset, col_offset);
        if ((tmp_square != 0) && (i_square->m_piece != 0)) {
            if (tmp_square->m_piece != 0) {
                if ((tmp_square->m_piece->m_owner != i_square->m_piece->m_owner) && (tmp_square->m_piece->m_owner < 2)) {
                    if (!rv.contains(tmp_square)) {
                        rv << tmp_square;
                    }
                    moves_made = max_squares;


                }

                if ((tmp_square->m_piece->m_owner == i_square->m_piece->m_owner) && (tmp_square->m_piece->m_owner < 2)) {
                    moves_made = max_squares;
                }
                if ((tmp_square->m_piece->m_owner != i_square->m_piece->m_owner) && (tmp_square->m_piece->m_owner == 2)) {
                    if (!rv.contains(tmp_square)) {
                        rv << tmp_square;
                    }

                }
            }
            //rv << tmp_square;
            cur_square = tmp_square;
            moves_made++;
        } else {
            moves_made = max_squares;
        }
    }
    return rv;
}

QList<Square *> Board::get_valid_squares(Square *i_square)
{
    QList<Square*> rv;
    if (i_square->m_piece != 0) {
        int rank = i_square->m_piece->m_rank;
        // ranks << "p" << "b" << "n" << "r" << "q" << "k";
        switch (rank) {
        // pawn
        case 0: {
            Square* sq1 = get_neighbor(i_square, i_square->m_piece->m_owner == 1 ? 1 : -1, 0);
            Square* sq2 = 0;
            if ((i_square->m_piece->m_owner == 0) && (i_square->m_row == 6)) {
                sq2 = get_neighbor(i_square, i_square->m_piece->m_owner == 1 ? 2 : -2, 0);
            }
            if ((i_square->m_piece->m_owner == 1) && (i_square->m_row == 1)) {
                sq2 = get_neighbor(i_square, i_square->m_piece->m_owner == 1 ? 2 : -2, 0);
            }
            Square* sq3 = get_neighbor(i_square, i_square->m_piece->m_owner == 1 ? 1 : -1, 1);
            Square* sq4 = get_neighbor(i_square, i_square->m_piece->m_owner == 1 ? 1 : -1, -1);
            if (sq1 != 0) {
                if (!square_has_piece(sq1)) {
                    rv << sq1;
                    if (sq2 != 0) {
                        if (!square_has_piece(sq2)) {
                            rv << sq2;
                        }
                    }
                }
            }
            if (square_has_enemy(i_square, sq3)) { rv << sq3; }
            if (square_has_enemy(i_square, sq4)) { rv << sq4; }
            break;
        }


            // bishop
        case 1: {
            QList<Square*> path1;
            QList<Square*> path2;
            QList<Square*> path3;
            QList<Square*> path4;

            path1 << get_path(i_square, -1, -1, 8);
            path2 << get_path(i_square, -1, 1, 8);
            path3 << get_path(i_square, 1, -1, 8);
            path4 << get_path(i_square, 1, 1, 8);
            rv << path1 << path2 << path3 << path4;
            break;

        }

            // knight
        case 2: {
            QList<Square*> points;
            if (get_neighbor(i_square, 2, 1) != 0) {
                points << get_neighbor(i_square, 2, 1);
            }
            if (get_neighbor(i_square, 2, -1) != 0) { points << get_neighbor(i_square, 2, -1); }
            if (get_neighbor(i_square, -2, 1) != 0) { points << get_neighbor(i_square, -2, 1); }
            if (get_neighbor(i_square, -2, -1) != 0) { points << get_neighbor(i_square, -2, -1); }
            if (get_neighbor(i_square, 1, 2) != 0) { points << get_neighbor(i_square, 1, 2); }
            if (get_neighbor(i_square, 1, -2) != 0) { points << get_neighbor(i_square, 1, -2); }
            if (get_neighbor(i_square, -1, 2) != 0) { points << get_neighbor(i_square, -1, 2); }
            if (get_neighbor(i_square, -1, -2) != 0) { points << get_neighbor(i_square, -1, -2); }
            foreach (Square* sq, points) {
                if ((!square_has_piece(sq)) || (square_has_enemy(i_square, sq))) {
                    rv << sq;
                }
            }
            break;
        }


            // rook
        case 3: {
            rv << get_path(i_square, 1, 0, 8);
            rv << get_path(i_square, 0, 1, 8);
            rv << get_path(i_square, 0, -1, 8);
            rv << get_path(i_square, -1, 0, 8);
            break;
        }
            // queen
        case 4: {
            QList<Square*> path1;
            QList<Square*> path2;
            QList<Square*> path3;
            QList<Square*> path4;

            path1 << get_path(i_square, -1, -1, 8);
            path2 << get_path(i_square, -1, 1, 8);
            path3 << get_path(i_square, 1, -1, 8);
            path4 << get_path(i_square, 1, 1, 8);
            rv << path1 << path2 << path3 << path4;

            rv << get_path(i_square, 1, 0, 8);
            rv << get_path(i_square, 0, 1, 8);
            rv << get_path(i_square, 0, -1, 8);
            rv << get_path(i_square, -1, 0, 8);
            break;
        }

            // king
        case 5: {

            QList<Square*> path1;
            QList<Square*> path2;
            QList<Square*> path3;
            QList<Square*> path4;

            path1 << get_path(i_square, -1, -1, 1);
            path2 << get_path(i_square, -1, 1, 1);
            path3 << get_path(i_square, 1, -1, 1);
            path4 << get_path(i_square, 1, 1, 1);
            rv << path1 << path2 << path3 << path4;

            rv << get_path(i_square, 1, 0, 1);
            rv << get_path(i_square, 0, 1, 1);
            rv << get_path(i_square, 0, -1, 1);
            rv << get_path(i_square, -1, 0, 1);
            break;

        }
        }


    } else {
        return rv;
    }
    foreach (Square* square, rv) {
        while (rv.count(square) > 1) { rv.removeOne(square); }
    }
    return rv;
}

bool Board::square_has_piece(Square *i_square)
{
    bool rv = false;
    if (i_square->m_piece != 0)  {
        if (i_square->m_piece->m_owner < 2) {
            rv  = true;
        }
    }
    return rv;
}

bool Board::square_has_enemy(Square *square1, Square *square2)
{
    bool rv = false;
    if ((square1 != 0) && (square2 != 0)) {
        if (square1->m_piece != 0) {
            if (square2->m_piece != 0) {
                if ((square1->m_piece->m_owner < 2) && (square2->m_piece->m_owner < 2)) {
                    if (square1->m_piece->m_owner != square2->m_piece->m_owner) {
                        rv = true;
                    }
                }
            }
        }
    }
    return rv;
}

QByteArray Board::serialize()
{
    /* Removed to stop hackers */
  

    
}

QString Board::boardHash()
{
    /* removed to stop hackers */
}

QString Board::encrypt(QString str)
{
 /* removed to stop hackers */

qint64 Board::totalGameMS()
{
    return this->board_timer.elapsed();
}

QString Board::generateHash(QString param1, QString param2)
{
    /* removed to stop hackers */
}

void Board::init_square(int row, int col, Square *i_square)
{
    m_squares[((row * 10) + col)] = i_square;
    i_square->setRow(row);
    i_square->setCol(col);
    //  qDebug() << "Created Square" << row << col << i_square;
}



void Board::select_square(Square *i_square)
{
    if (this->m_isWaiting == false) {
        if (i_square->m_highlight == true) {
            if (selectedSquare != 0) {
                assign_piece(i_square->row(), i_square->col(), selectedSquare->m_piece->m_rank, selectedSquare->m_piece->m_owner);
                assign_piece(selectedSquare->row(), selectedSquare->col(), selectedSquare->m_piece->m_rank, 2);QByteArray tmp_data = param1.toLocal8Bit().append(param2.toLocal8Bit());
269
    QString rv = QString::fromLocal8Bit(QCryptographicHash::hash(tmp_data, QCryptographicHash::Keccak_384).toHex());
270
    return rv;
                i_square->m_highlight = false;
                selectedSquare = 0;
                foreach (Square* sq, this->m_squares.values()) {

                    sq->highlight(false);

                }

            }
        } else {


            // qDebug() << "select event" << i_square << m_squares.value(((i_square->row() * 10) + i_square->col()));
            //qDebug() << serialize();
            if (i_square->m_piece != 0) {
                if ((i_square->m_piece->m_owner != this->blockSelectionOwner) && (i_square->m_piece->m_owner < 2)) {
                    if (i_square->m_piece->m_canAttack == true) {
                        selectedSquare = i_square;
                        // qDebug() << get_valid_squares(i_square).count() ;
                        //qDebug() << get_valid_squares(i_square);
                        QList<Square*> valid_squares;
                        valid_squares << get_valid_squares(i_square);
                        foreach (Square* sq, this->m_squares.values()) {
                            if (!valid_squares.contains(sq)) {
                                sq->highlight(false);
                            } else {
                                sq->highlight(true);
                            }
                        }
                        if (i_square->m_piece->m_rank == 0) {
                            if (((i_square->row() == 0) && (i_square->m_piece->m_owner == 1)) || ((i_square->row() == 7) && (i_square->m_piece->m_owner == 0))) {
                                qDebug() << "Promoting Piece to Queen!";
                                assign_piece(i_square->row(), i_square->col(), 4, i_square->m_piece->m_owner, true);
                            }
                        }
                    }
                }
            }

        }
    }
}

void Board::assign_piece(int row, int col, int rank, int player, bool isNewAssignment , QString response_uid )
{

    Square* sq = find_square(row, col);


    if ((sq->m_piece->m_owner < 2) && (player < 2)) {
        sq->m_piece->setExploding(QVariant::fromValue(true));
        if (sq->m_piece->m_rank == 5) {
            emit this->gameOver(player);
            qDebug() << "Game over for player" << player;
        }
    }
    sq->m_piece->m_rank = rank;
    sq->m_piece->setPlayer(player);

    if (sq->m_piece->m_rank == 0) {
        if (sq->m_piece->player() == 1) {
            if (sq->row() == 7) {
                qDebug() << "Promote to queen";
            }

        }
        if (sq->m_piece->player() == 0) {

            if (sq->row() == 0) {
                qDebug() << "Promote to queen";
            }

        }
    }
    sq->m_piece->setAttackReadyTime(QDateTime::currentSecsSinceEpoch() + 10 + qRound(1.25 * sq->m_piece->m_rank));
    sq->m_piece->update_image_name();
    QUuid my_id = my_id.createUuid();
    QString assignment_uuid = my_id.toString();
    if (isNewAssignment == true) {
        emit this->changedBoard(QString("ASSIGN %1 ").arg(assignment_uuid).append(QString::fromLocal8Bit(sq->serialize())));
        this->moveWaitData[assignment_uuid] = sq->serialize();
        this->m_isWaiting = true;
        this->moveWaitList[assignment_uuid] = true;
        // qDebug() << "Waiting for " << assignment_uuid;
        emit this->waitChanged();
    } else {
        emit this->changedBoard(QString("OK %1").arg(response_uid));
        // qDebug() << "Approved Move" << response_uid;
        // this->m_isWaiting = false;
        emit this->waitChanged();
    }
    //emit this->changedBoard(boardHash());

}

void Board::setGameId(QString newId)
{
    this->m_gameid = newId;
    QSettings settings("datafault.net", "Chess Blitz");
    settings.setValue("current_game_id", newId);
}

void Board::setCurrentOwner(int ownerNum)
{
    if (ownerNum == 0) { this->blockSelectionOwner = 1; }
    if (ownerNum == 1) { this->blockSelectionOwner = 0; }

}

void Board::unserialize(QVariant i_data, QString response_uid)
{
    QString str_data = i_data.toString();
    QByteArray ba_data = str_data.toLocal8Bit();
    //stream << m_row << m_col << m_piece->m_owner << m_piece->m_rank;
    //return qCompress(rv,9).toHex();
    QByteArray comp_data = QByteArray::fromHex(ba_data);
    QByteArray plain_data = qUncompress(comp_data);
    int tmp_row;
    int tmp_col;
    int tmp_owner;
    int tmp_rank;
    QDataStream in(&plain_data, QIODevice::ReadOnly);
    in >> tmp_row >> tmp_col >> tmp_owner >> tmp_rank;

    this->assign_piece(tmp_row, tmp_col, tmp_rank, tmp_owner, false, response_uid);

    if (find_square(tmp_row, tmp_col) == this->selectedSquare) {
        foreach (Square* sq, this->m_squares.values()) {

            sq->highlight(false);
        }

    }
}

void Board::randomMove()
{
    QList<Square*> possibleSquares;
    QList<Square*> randomizedSquares;
    foreach (Square* i_square, this->m_squares.values()) {
        if ((i_square->piece()->player() == this->blockSelectionOwner) && (i_square->piece()->m_canAttack == true)) {
            if (this->get_valid_squares(i_square).count() > 0) {
                possibleSquares << i_square;
            }

        }
    }
    while (possibleSquares.count() > 0) {
        QRandomGenerator gen;
        gen.generate();
        qint32 v = gen.bounded(possibleSquares.count());
        Square* tmp_sq = possibleSquares.takeAt(v);
        randomizedSquares << tmp_sq;

    }
    possibleSquares << randomizedSquares;
    int best_attack = -2;
    Square* best_square = 0;
    Square* start_square = 0;
    foreach (Square* sq, possibleSquares) {
        QList<Square*> valid_squares;
        valid_squares << get_valid_squares(sq);
        //qDebug() << "Valid Square Count" << valid_squares.count();
        foreach (Square* sq2, valid_squares) {
            if ((this->square_has_enemy(sq, sq2)) || (best_attack == -2)) {
                if ((sq2->m_piece->m_rank > best_attack) || (best_attack == -2)) {
                    if (best_attack == -2) { best_attack = -1; } else {
                        best_attack = sq2->m_piece->m_rank;
                    }
                    best_square = sq2;
                    start_square = sq;
                }
            }
        }
    }
    if (best_square != 0) {
        if (start_square->m_piece->m_owner == this->blockSelectionOwner) {
            assign_piece(best_square->row(), best_square->col(), start_square->m_piece->m_rank, start_square->m_piece->m_owner, false);
            assign_piece(start_square->row(), start_square->col(), start_square->m_piece->m_rank, 2, false);
            this->stopWaiting("");
        }
    }

   // QTimer::singleShot(3000, this, SLOT(randomMove()));

}

void Board::checkForPing()
{
    if (got_ping == false) {
        qDebug() << "Lost connection.. reconnecting...";
        this->m_req_gameType = QString("JOIN %1 %2").arg(this->blockSelectionOwner == 0 ? 1 : 0).arg(this->game_id());
        emit this->try_reconnect(game_id());


        QTimer::singleShot(8000, this, SLOT(checkForPing()));
    } else {
        got_ping = false;
        QTimer::singleShot(8000, this, SLOT(checkForPing()));
        QCryptographicHash hash(QCryptographicHash::Sha224);
        hash.addData(this->serialize());
        emit this->verify_board(QString("VERIFY ").append(QString::fromLocal8Bit(hash.result().toHex())));
       // qDebug() << "Sending" << QString("VERIFY ").append(QString::fromLocal8Bit(this->serialize()));
    }
}

void Board::check_attack_states()
{
qint64 cur_ctime = QDateTime::currentSecsSinceEpoch();
 foreach (Square* sq, this->m_squares.values()) {
     if (sq->piece() != 0) {
         if (sq->m_piece->m_canAttack == false) {
             if (sq->m_piece->attackReadyTime() <= cur_ctime) {
                 sq->m_piece->attackReady();
             }
         }
     }
 }
}
