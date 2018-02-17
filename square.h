#ifndef SQUARE_H
#define SQUARE_H

#include <QObject>
#include <QQuickItem>

class Piece;
class Square : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(int row READ row WRITE setRow)
    Q_PROPERTY(int col READ col WRITE setCol)
public:
    Square();

    int m_row;
    int m_col;
    Piece* m_piece;
    Q_INVOKABLE int row() { return m_row; }
    Q_INVOKABLE int col() { return m_col; }
    Q_INVOKABLE Piece* piece() { return m_piece; }
    bool m_highlight;
    QByteArray serialize();
signals:
    void highlight_changed(QVariant rv);

public slots:
    void setRow(int new_row) { m_row = new_row; }
    void setCol(int new_col) { m_col = new_col; }
    void setPiece(Piece* new_piece) { m_piece = new_piece; }
    void highlight(bool should_highlight);
};

#endif // SQUARE_H